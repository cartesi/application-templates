import {
  type AdvanceRequest,
  type InspectRequest,
  Rollup,
} from "@cartesi/rollup";

const rollup = new Rollup();

const handleAdvance = (request: AdvanceRequest): boolean => {
  console.log(
    `Received advance request from ${request.msgSender} with index ${request.index} and payload 0x${request.payload.toString("hex")}`,
  );

  // emit outputs with rollup.emitNotice, rollup.emitVoucher or rollup.emitReport
  // return false to reject the input
  return true;
};

const handleInspect = (request: InspectRequest): void => {
  console.log(
    `Received inspect request with payload 0x${request.payload.toString("hex")}`,
  );

  // answer inspect requests with rollup.emitReport
};

await rollup.run({ advance: handleAdvance, inspect: handleInspect });
