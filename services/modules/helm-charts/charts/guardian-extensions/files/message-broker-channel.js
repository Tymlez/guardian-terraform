"use strict";
var __awaiter =
  (this && this.__awaiter) ||
  function (thisArg, _arguments, P, generator) {
    function adopt(value) {
      return value instanceof P
        ? value
        : new P(function (resolve) {
            resolve(value);
          });
    }
    return new (P || (P = Promise))(function (resolve, reject) {
      function fulfilled(value) {
        try {
          step(generator.next(value));
        } catch (e) {
          reject(e);
        }
      }
      function rejected(value) {
        try {
          step(generator["throw"](value));
        } catch (e) {
          reject(e);
        }
      }
      function step(result) {
        result.done
          ? resolve(result.value)
          : adopt(result.value).then(fulfilled, rejected);
      }
      step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
  };
var __asyncValues =
  (this && this.__asyncValues) ||
  function (o) {
    if (!Symbol.asyncIterator)
      throw new TypeError("Symbol.asyncIterator is not defined.");
    var m = o[Symbol.asyncIterator],
      i;
    return m
      ? m.call(o)
      : ((o =
          typeof __values === "function" ? __values(o) : o[Symbol.iterator]()),
        (i = {}),
        verb("next"),
        verb("throw"),
        verb("return"),
        (i[Symbol.asyncIterator] = function () {
          return this;
        }),
        i);
    function verb(n) {
      i[n] =
        o[n] &&
        function (v) {
          return new Promise(function (resolve, reject) {
            (v = o[n](v)), settle(resolve, reject, v.done, v.value);
          });
        };
    }
    function settle(resolve, reject, d, v) {
      Promise.resolve(v).then(function (v) {
        resolve({ value: v, done: d });
      }, reject);
    }
  };
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod };
  };
Object.defineProperty(exports, "__esModule", { value: true });
exports.MessageBrokerChannel = void 0;
const assert_1 = __importDefault(require("assert"));
const newrelic_1 = __importDefault(require("newrelic"));
const nats_1 = require("nats");
const message_response_1 = require("../models/message-response");
const interfaces_1 = require("@guardian/interfaces");
const MQ_TIMEOUT = 300000;
/**
 * Message Chunk Size ~ 10 MB
 */
const MQ_MESSAGE_CHUNK = 10000000;
const reqMap = new Map();
const chunkMap = new Map();
/**
 * Message broker channel
 */
class MessageBrokerChannel {
  constructor(channel, channelName) {
    this.channel = channel;
    this.channelName = channelName;
    const fn = (_sub) => {
      var _sub_1, _sub_1_1;
      return __awaiter(this, void 0, void 0, function* () {
        var e_1, _a;
        try {
          for (
            _sub_1 = __asyncValues(_sub);
            (_sub_1_1 = yield _sub_1.next()), !_sub_1_1.done;

          ) {
            const m = _sub_1_1.value;
            try {
              if (!m.headers) {
                console.error("No headers");
                continue;
              }
              if (!m.headers.has("chunks")) {
                console.error("No chunks");
                continue;
              }
              const messageId = m.headers.get("messageId");
              const chunkNumber = m.headers.get("chunk");
              const countChunks = m.headers.get("chunks");
              let requestChunks;
              if (chunkMap.has(messageId)) {
                requestChunks = chunkMap.get(messageId);
                requestChunks.push({ data: m.data, index: chunkNumber });
              } else {
                requestChunks = [{ data: m.data, index: chunkNumber }];
                chunkMap.set(messageId, requestChunks);
              }
              if (requestChunks.length < countChunks) {
                continue;
              } else {
                chunkMap.delete(messageId);
              }
              if (reqMap.has(messageId)) {
                const requestChunksSorted = new Array(requestChunks.length);
                for (const requestChunk of requestChunks) {
                  requestChunksSorted[requestChunk.index - 1] =
                    requestChunk.data;
                }
                const dataObj = JSON.parse(
                  Buffer.concat(requestChunksSorted).toString()
                );
                const func = reqMap.get(messageId);
                func(dataObj);
              } else {
                continue;
              }
            } catch (e) {
              console.error(e);
            }
          }
        } catch (e_1_1) {
          e_1 = { error: e_1_1 };
        } finally {
          try {
            if (_sub_1_1 && !_sub_1_1.done && (_a = _sub_1.return))
              yield _a.call(_sub_1);
          } finally {
            if (e_1) throw e_1.error;
          }
        }
      });
    };
    fn(
      this.channel.subscribe("response-message", {
        queue: process.env.SERVICE_CHANNEL,
      })
    ).then();
  }
  /**
   * Get target
   * @param eventType
   * @private
   */
  getTarget(eventType) {
    if (eventType.includes(this.channelName) || eventType.includes("*")) {
      return eventType;
    }
    return `${this.channelName}.${eventType}`;
  }
  /**
   * Subscribe to the MQ event
   * @param eventType : target event type @example  ipfs-clients.get-file
   * @param handleFunc: the call back function to process the request
   */
  response(eventType, handleFunc) {
    return __awaiter(this, void 0, void 0, function* () {
      const target = this.getTarget(eventType);
      // console.log('MQ subscribed: %s', target);
      const sub = this.channel.subscribe(target, {
        queue: process.env.SERVICE_CHANNEL,
      });
      const fn = (_sub) => {
        var _sub_2, _sub_2_1;
        return __awaiter(this, void 0, void 0, function* () {
          var e_2, _a;
          try {
            for (
              _sub_2 = __asyncValues(_sub);
              (_sub_2_1 = yield _sub_2.next()), !_sub_2_1.done;

            ) {
              const m = _sub_2_1.value;
              yield newrelic_1.default.startBackgroundTransaction(
                target,
                "Nats response",
                () =>
                  __awaiter(this, void 0, void 0, function* () {
                    const transaction = newrelic_1.default.getTransaction();
                    try {
                      let payload;
                      const messageId = m.headers.get("messageId");
                      if (m.headers.has("chunks")) {
                        const chunkNumber = m.headers.get("chunk");
                        const countChunks = m.headers.get("chunks");
                        let requestChunks;
                        if (chunkMap.has(messageId)) {
                          requestChunks = chunkMap.get(messageId);
                          requestChunks.push({
                            data: m.data,
                            index: chunkNumber,
                          });
                        } else {
                          requestChunks = [
                            { data: m.data, index: chunkNumber },
                          ];
                          chunkMap.set(messageId, requestChunks);
                        }
                        if (requestChunks.length < countChunks) {
                          m.respond(new Uint8Array(0));
                          return;
                        } else {
                          chunkMap.delete(messageId);
                          m.respond(new Uint8Array(0));
                        }
                        const requestChunksSorted = new Array(
                          requestChunks.length
                        );
                        for (const requestChunk of requestChunks) {
                          requestChunksSorted[requestChunk.index - 1] =
                            requestChunk.data;
                        }
                        payload = JSON.parse(
                          Buffer.concat(requestChunksSorted).toString()
                        );
                      } else {
                        payload = JSON.parse(m.data.toString());
                      }
                      let responseMessage;
                      try {
                        responseMessage = yield handleFunc(payload);
                      } catch (error) {
                        responseMessage = new message_response_1.MessageError(
                          error,
                          error.code
                        );
                      }
                      const head = (0, nats_1.headers)();
                      head.append("messageId", messageId);
                      const payloadBuffer = Buffer.from(
                        JSON.stringify(responseMessage)
                      );
                      let offset = 0;
                      const chunks = [];
                      while (offset < payloadBuffer.length) {
                        chunks.push(
                          payloadBuffer.subarray(
                            offset,
                            offset + MQ_MESSAGE_CHUNK > payloadBuffer.length
                              ? payloadBuffer.length
                              : offset + MQ_MESSAGE_CHUNK
                          )
                        );
                        offset = offset + MQ_MESSAGE_CHUNK;
                      }
                      head.set("chunks", chunks.length.toString());
                      for (let i = 0; i < chunks.length; i++) {
                        const chunk = chunks[i];
                        head.set("chunk", (i + 1).toString());
                        this.channel.publish("response-message", chunk, {
                          headers: head,
                        });
                      }
                    } catch (e) {
                      console.error(e.message);
                    } finally {
                      transaction.end();
                    }
                  })
              );
            }
          } catch (e_2_1) {
            e_2 = { error: e_2_1 };
          } finally {
            try {
              if (_sub_2_1 && !_sub_2_1.done && (_a = _sub_2.return))
                yield _a.call(_sub_2);
            } finally {
              if (e_2) throw e_2.error;
            }
          }
        });
      };
      yield fn(sub);
    });
  }
  /**
   * sending the request to the MQ and waiting for response
   * @param eventType target subscription , it should follow the pattern: target subscription . event type (ex : ipfs-clients.get-file)
   * @param payload input data for event
   * @param timeout timeout in milliseconds, this will overwrite default env var MQ_TIMEOUT varlue @default 30000
   * @returns MessageResponse or Error response
   */
  request(eventType, payload, timeout) {
    return __awaiter(this, void 0, void 0, function* () {
      return yield newrelic_1.default.startBackgroundTransaction(
        eventType,
        "Nats request",
        () =>
          __awaiter(this, void 0, void 0, function* () {
            const transaction = newrelic_1.default.getTransaction();
            try {
              const messageId = (0, interfaces_1.GenerateUUIDv4)();
              const head = (0, nats_1.headers)();
              head.append("messageId", messageId);
              let stringPayload;
              switch (typeof payload) {
                case "string":
                  stringPayload = payload;
                  break;
                case "object":
                  stringPayload = JSON.stringify(payload);
                  break;
                default:
                  stringPayload = "{}";
              }
              return new Promise((resolve, reject) => {
                reqMap.set(messageId, (data) => {
                  resolve(data);
                  reqMap.delete(messageId);
                });
                const payloadBuffer = Buffer.from(stringPayload);
                let offset = 0;
                const chunks = [];
                while (offset < payloadBuffer.length) {
                  chunks.push(
                    payloadBuffer.subarray(
                      offset,
                      offset + MQ_MESSAGE_CHUNK > payloadBuffer.length
                        ? payloadBuffer.length
                        : offset + MQ_MESSAGE_CHUNK
                    )
                  );
                  offset = offset + MQ_MESSAGE_CHUNK;
                }
                head.set("chunks", chunks.length.toString());
                let errorHandler = (error) => {
                  reqMap.delete(messageId);
                  // Nats no subscribe error
                  if (error.code === "503") {
                    console.warn(
                      "No listener for message event type =  %s",
                      eventType
                    );
                    resolve(null);
                  } else {
                    console.error(error.message, error.stack, error);
                    reject(error);
                  }
                };
                for (let i = 0; i < chunks.length; i++) {
                  const chunk = chunks[i];
                  head.set("chunk", (i + 1).toString());
                  this.channel
                    .request(eventType, chunk, {
                      timeout: timeout || MQ_TIMEOUT,
                      headers: head,
                    })
                    .then(
                      () => null,
                      (error) => {
                        if (errorHandler) {
                          errorHandler(error);
                          errorHandler = null;
                        }
                      }
                    );
                }
              });
            } catch (error) {
              return new Promise((resolve, reject) => {
                // Nats no subscribe error
                if (error.code === "503") {
                  console.warn(
                    "No listener for message event type =  %s",
                    eventType
                  );
                  resolve(null);
                  return;
                }
                console.error(error.message, error.stack, error);
                reject(error);
              });
            } finally {
              transaction.end();
            }
          })
      );
    });
  }
  /**
   * Publish message to all Nats client subscribers
   * @param eventType
   * @param data
   * @param allowError
   */
  publish(eventType, data, allowError = true) {
    try {
      console.log("MQ publish: %s", eventType);
      const messageId = (0, interfaces_1.GenerateUUIDv4)();
      const head = (0, nats_1.headers)();
      head.append("messageId", messageId);
      const sc = (0, nats_1.JSONCodec)();
      this.channel.publish(eventType, sc.encode(data), { headers: head });
    } catch (e) {
      console.error(e.message, e.stack, e);
      if (!allowError) {
        throw e;
      }
    }
  }
  /**
   * Subscribe for subject
   * @param subj
   * @param callback
   */
  subscribe(subj, callback) {
    const sub = this.channel.subscribe(subj, {
      queue: process.env.SERVICE_CHANNEL,
    });
    const fn = (_sub) => {
      var _sub_3, _sub_3_1;
      return __awaiter(this, void 0, void 0, function* () {
        var e_3, _a;
        try {
          for (
            _sub_3 = __asyncValues(_sub);
            (_sub_3_1 = yield _sub_3.next()), !_sub_3_1.done;

          ) {
            const m = _sub_3_1.value;
            try {
              const dataObj = JSON.parse(
                (0, nats_1.StringCodec)().decode(m.data)
              );
              callback(dataObj);
            } catch (e) {
              console.error(e.message);
            }
          }
        } catch (e_3_1) {
          e_3 = { error: e_3_1 };
        } finally {
          try {
            if (_sub_3_1 && !_sub_3_1.done && (_a = _sub_3.return))
              yield _a.call(_sub_3);
          } finally {
            if (e_3) throw e_3.error;
          }
        }
      });
    };
    fn(sub);
  }
  /**
   * Create the Nats MQ connection
   * @param connectionName
   * @returns
   */
  static connect(connectionName) {
    return __awaiter(this, void 0, void 0, function* () {
      (0,
      assert_1.default)(process.env.MQ_ADDRESS, "Missing MQ_ADDRESS environment variable");
      return (0, nats_1.connect)({
        servers: [process.env.MQ_ADDRESS],
        name: connectionName,
        reconnectDelayHandler: () => 2000,
        maxReconnectAttempts: -1, // reconnect forever
      });
    });
  }
}
exports.MessageBrokerChannel = MessageBrokerChannel;
//# sourceMappingURL=message-broker-channel.js.map
