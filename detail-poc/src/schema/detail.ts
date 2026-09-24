import type { DetailId, OperatorId, PersonaId } from "../ids.js";

export type DetailStatus = "active" | "paused";

/**
 * DETAIL — the System / AI role. CTAs manifest as speech, not buttons.
 * Source: object-map.json → objects[].name === "DETAIL"
 *
 * NOTE: DETAIL is 1:1 with OPERATOR ("has 1 OPERATOR" both ways). Per the
 * handoff's instruction to model 1:1s as separate tables anyway, this stays
 * its own row; `operatorId` is the owning FK (unique).
 */
export interface DetailRow {
  /** INFRASTRUCTURE: primary key. */
  id: DetailId;

  // core_content
  name: string;

  // metadata — four voice sliders modeled uniformly as 0-100 positions.
  voiceCalmToEnergetic: number;
  voiceFactsToConversational: number;
  voiceProfessionalToPlayful: number;
  voiceHumor: number;
  tenure: string;
  knowledgeLevel: number;
  avgCuesPerDay: number;
  status: DetailStatus;

  // relationships
  /** Owning side of the 1:1 with OPERATOR. */
  operatorId: OperatorId;
  personaId: PersonaId;

  // Reverse/derived, not stored here:
  //   - has 0-many THRESHOLD (learned)    -> Threshold.detailId
  //   - has 0-many CUE (delivered)        -> Cue.detailId
  //   - has 0-many ACTION (taken)         -> Action.detailId
  //   - has 0-many PROPOSAL (pending)     -> Proposal.detailId
  //   - has 0-many CUE DECISION (made)    -> CueDecision.detailId
  //   - has 0-many CAMPAIGN (drafted)     -> Campaign.draftedByDetailId
  //     (INFRASTRUCTURE ADDITION: campaign.json only has an "Authored By"
  //      string metadata, no FK. We added draftedByDetailId to realize this
  //      declared relationship at all — see campaign.ts.)
  //   - has 0-many PATTERN (observed)     -> Pattern.detailId
}
