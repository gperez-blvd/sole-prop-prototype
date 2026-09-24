/**
 * Generic in-memory table. Every schema row type has an `id` field of some
 * branded string type; this class doesn't care which — it's identical
 * machinery for all 26 tables (plus the join tables, keyed by a
 * synthesized composite key instead).
 */
export class UnknownRowError extends Error {
  constructor(table: string, id: string) {
    super(`${table}: no row with id "${id}"`);
    this.name = "UnknownRowError";
  }
}

export class Table<Id extends string, Row extends { id: Id }> {
  private readonly rows = new Map<Id, Row>();

  constructor(private readonly name: string) {}

  insert(row: Row): Row {
    if (this.rows.has(row.id)) {
      throw new Error(`${this.name}: id "${row.id}" already exists`);
    }
    this.rows.set(row.id, row);
    return row;
  }

  get(id: Id): Row | undefined {
    return this.rows.get(id);
  }

  getOrThrow(id: Id): Row {
    const row = this.rows.get(id);
    if (!row) throw new UnknownRowError(this.name, id);
    return row;
  }

  has(id: Id): boolean {
    return this.rows.has(id);
  }

  /** Structural update — merges `patch` onto the existing row. */
  update(id: Id, patch: Partial<Row>): Row {
    const existing = this.getOrThrow(id);
    const next = { ...existing, ...patch };
    this.rows.set(id, next);
    return next;
  }

  list(): Row[] {
    return Array.from(this.rows.values());
  }

  find(predicate: (row: Row) => boolean): Row[] {
    return this.list().filter(predicate);
  }

  findOne(predicate: (row: Row) => boolean): Row | undefined {
    return this.list().find(predicate);
  }

  count(): number {
    return this.rows.size;
  }

  /**
   * Delete, subject to the dependents check the caller supplies.
   * `onDependents` defaults to "throw" — see relationships.ts: cascade
   * behavior is UNSPECIFIED for every relationship in the map, so the
   * store refuses to guess. A caller must explicitly say "cascade" or
   * "restrict" at the call site; that choice is then attributable to the
   * caller, not silently baked into the schema.
   */
  delete(
    id: Id,
    dependents: () => { table: string; count: number }[],
    onDependents: "throw" | "cascade" | "restrict" = "throw",
  ): void {
    const found = dependents();
    if (found.length > 0) {
      if (onDependents === "throw") {
        const summary = found.map((d) => `${d.count} ${d.table}`).join(", ");
        throw new Error(
          `${this.name}: refusing to delete "${id}" — has dependents (${summary}) ` +
            `and no onDelete policy is specified in the map. Pass onDependents: 'cascade' | 'restrict' explicitly.`,
        );
      }
      if (onDependents === "restrict") {
        throw new Error(`${this.name}: delete of "${id}" restricted — dependents exist.`);
      }
      // 'cascade' is the caller's explicit choice; the caller is responsible
      // for actually deleting the dependents before/after this call. This
      // table only removes its own row.
    }
    this.rows.delete(id);
  }
}
