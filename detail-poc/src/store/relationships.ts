/**
 * Derives the full relationship registry directly from data/object-map.json
 * — rather than hand-transcribing ~120 nested_objects entries into TS (and
 * risking drift from the source of truth), we read the map itself. This
 * file is also where the three required hand-back lists come from:
 *   - unratified (△) attributes and relationships
 *   - dependency rules stubbed as UNSPECIFIED (i.e. every relationship —
 *     the map never says what happens to nested rows on delete)
 *   - the "narrower in reality" cardinality the handoff calls out
 *
 * "Anything invented to make it run" (join tables with no map counterpart,
 * infrastructure FKs, etc.) is NOT derivable from the JSON — those are
 * listed by hand in report.ts, next to comments in the schema files that
 * introduce them.
 */
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

interface RawAttribute {
  name: string;
  example: string;
}

interface RawNestedObject {
  cardinality: string;
  object: string;
  nature: string;
}

interface RawObject {
  name: string;
  core_content: RawAttribute[];
  metadata: RawAttribute[];
  nested_objects: RawNestedObject[];
}

interface RawObjectMap {
  title: string;
  objects: RawObject[];
}

const dataPath = fileURLToPath(new URL("../../data/object-map.json", import.meta.url));
const objectMap = JSON.parse(readFileSync(dataPath, "utf8")) as RawObjectMap;

export interface RelationshipDescriptor {
  fromObject: string;
  cardinality: string;
  toObject: string;
  nature: string;
  /** The map never specifies this for any relationship — see handoff §3. */
  onDelete: "UNSPECIFIED";
  unratified: boolean;
}

export const RELATIONSHIP_DESCRIPTORS: RelationshipDescriptor[] = objectMap.objects.flatMap((obj) =>
  obj.nested_objects.map((n) => ({
    fromObject: obj.name,
    cardinality: n.cardinality,
    toObject: n.object,
    nature: n.nature,
    onDelete: "UNSPECIFIED" as const,
    unratified: n.nature.trim().startsWith("△"),
  })),
);

export interface UnratifiedAttribute {
  object: string;
  section: "core_content" | "metadata";
  field: string;
}

export const UNRATIFIED_ATTRIBUTES: UnratifiedAttribute[] = objectMap.objects.flatMap((obj) => [
  ...obj.core_content
    .filter((a) => a.name.trim().startsWith("△"))
    .map((a) => ({ object: obj.name, section: "core_content" as const, field: a.name })),
  ...obj.metadata
    .filter((a) => a.name.trim().startsWith("△"))
    .map((a) => ({ object: obj.name, section: "metadata" as const, field: a.name })),
]);

export const UNRATIFIED_RELATIONSHIPS: RelationshipDescriptor[] = RELATIONSHIP_DESCRIPTORS.filter(
  (r) => r.unratified,
);

/**
 * Relationships where the handoff itself says the declared cardinality is
 * looser than reality (currently just DAY→BRIEFING, 0-many really meaning
 * 0-2). Enforced at runtime in RelationalStore.createBriefing().
 */
export const TIGHTENED_CARDINALITIES: { fromObject: string; toObject: string; note: string }[] = [
  {
    fromObject: "DAY",
    toObject: "BRIEFING",
    note: "declared 'has 0-many BRIEFING'; really 0-2 (one brief, one debrief, by BRIEFING.Type). Enforced in RelationalStore.createBriefing().",
  },
];
