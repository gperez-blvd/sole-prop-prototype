import { test } from "node:test";
import assert from "node:assert/strict";
import { seed } from "../src/seed/seed.js";

/**
 * RelationalStore.clientMemory() — the CLIENT detail page's rollup. Tasha
 * has nine visits behind her; Maya's first was today. The page must be
 * backed by rows, grow with history, respect "that's not true", and never
 * carry anything from her chart.
 */

const endOfTuesday = new Date(2026, 8, 23, 23, 59);

test("Tasha: cadence, last of each service and what she buys all come from her history", () => {
  const { store, clientIds } = seed();
  const memory = store.clientMemory(clientIds.tasha, endOfTuesday);

  assert.equal(memory.visits.length, 9);
  assert.equal(memory.cadence?.days, 35);
  assert.equal(memory.cadence?.gapsObserved, 8);
  assert.equal(memory.cadence?.nextDueAround.toDateString(), new Date(2026, 9, 28).toDateString());
  assert.equal(memory.sentence, "Tasha rebooks about every five weeks — next around Oct 28.");

  const peel = memory.lastOfEach.find((l) => l.serviceName === "Chemical peel");
  assert.equal(peel?.date.toDateString(), new Date(2026, 6, 14).toDateString());

  assert.deepEqual(
    memory.productsBought.map((p) => [p.productName, p.times, p.lastBought.getMonth()]),
    [["Vitamin C serum", 4, 7]],
  );
});

test("Tasha: the stored belief agrees with the evidence it claims", () => {
  const { store, clientIds } = seed();
  const memory = store.clientMemory(clientIds.tasha, endOfTuesday);
  const pattern = store.patterns.getOrThrow(memory.cadence!.patternId);
  assert.equal(pattern.evidenceCount, memory.cadence!.gapsObserved);
  assert.equal(store.clients.getOrThrow(clientIds.tasha).rebookingCadenceDays, memory.cadence!.days);
});

test("a pattern DETAIL is still watching is never shown", () => {
  const { store, clientIds } = seed();
  const watching = store.patterns.find((p) => p.clientId === clientIds.tasha && p.status === "watching");
  assert.equal(watching.length, 1);
  const memory = store.clientMemory(clientIds.tasha, endOfTuesday);
  assert.equal(memory.noticed.length, 0);
});

test("memory grows over time: in January there was nothing to say yet", () => {
  const { store, clientIds } = seed();
  const memory = store.clientMemory(clientIds.tasha, new Date(2026, 0, 31));
  assert.equal(memory.visits.length, 2);
  assert.equal(memory.cadence, undefined);
  assert.equal(memory.sentence, undefined);
});

test("\"that's not true\" removes the cadence", () => {
  const { store, clientIds } = seed();
  const { patternId } = store.clientMemory(clientIds.tasha, endOfTuesday).cadence!;
  store.patterns.update(patternId, { status: "dismissed" });
  const memory = store.clientMemory(clientIds.tasha, endOfTuesday);
  assert.equal(memory.cadence, undefined);
  assert.equal(memory.sentence, undefined);
});

test("Maya: a first visit is a calm, nearly empty page", () => {
  const { store, clientIds } = seed();
  const memory = store.clientMemory(clientIds.maya, endOfTuesday);
  assert.equal(memory.visits.length, 1);
  assert.equal(memory.cadence, undefined);
  assert.equal(memory.sentence, undefined);
  assert.equal(memory.noticed.length, 0);
  assert.equal(memory.productsBought.length, 0);
});

test("nothing from her chart reaches the client page or the spoken line", () => {
  const { store, clientIds } = seed();
  const memory = store.clientMemory(clientIds.tasha, endOfTuesday);
  const chart = store.charts.findOne((c) => c.clientId === clientIds.tasha)!;
  const entries = store.chartEntries.find((e) => e.chartId === chart.id);
  assert.ok(chart.skinType);
  assert.ok(entries.length > 0);

  const serialized = JSON.stringify(memory);
  for (const clinical of [chart.skinType!, ...entries.map((e) => e.observations)]) {
    assert.ok(!serialized.includes(clinical), `client memory leaked chart text: ${clinical}`);
  }
});

test("Tasha's history sits on past days — Tuesday still collects $3,180", () => {
  const { store, dayTueId } = seed();
  assert.equal(store.dayStats(dayTueId).collected, 318000);
  assert.equal(store.dayStats(dayTueId).appointmentCount, 7);
});

test("the Clients list: everyone on file, most recently seen first", () => {
  const { store, businessId, clientIds } = seed();
  const directory = store.clientDirectory(businessId, endOfTuesday);
  assert.equal(directory.length, store.clients.find((c) => c.businessId === businessId).length);

  const seenTuesday = directory.filter((row) => row.lastVisit?.date.toDateString() === new Date(2026, 8, 23).toDateString());
  assert.ok(seenTuesday.some((row) => row.clientId === clientIds.tasha));
  assert.equal(directory[0]!.lastVisit!.date.getTime(), Math.max(...seenTuesday.map((row) => row.lastVisit!.date.getTime())));

  const dated = directory.filter((row) => row.lastVisit);
  const undated = directory.filter((row) => !row.lastVisit);
  assert.deepEqual(directory, [...dated, ...undated]);
  assert.deepEqual(undated.map((r) => r.fullName), [...undated.map((r) => r.fullName)].sort((a, b) => a.localeCompare(b)));
});

test("the Clients list only knows a last visit, never anything from a chart", () => {
  const { store, businessId, clientIds } = seed();
  const tasha = store.clientDirectory(businessId, endOfTuesday).find((r) => r.clientId === clientIds.tasha)!;
  assert.deepEqual(Object.keys(tasha).sort(), ["clientId", "fullName", "lastVisit"]);
  const chart = store.charts.findOne((c) => c.clientId === clientIds.tasha)!;
  assert.ok(!JSON.stringify(tasha).includes(chart.skinType!));
});
