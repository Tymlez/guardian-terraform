"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function (o, m, k, k2) {
  if (k2 === undefined) k2 = k;
  var desc = Object.getOwnPropertyDescriptor(m, k);
  if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
    desc = { enumerable: true, get: function () { return m[k]; } };
  }
  Object.defineProperty(o, k2, desc);
}) : (function (o, m, k, k2) {
  if (k2 === undefined) k2 = k;
  o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function (o, v) {
  Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function (o, v) {
  o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
  if (mod && mod.__esModule) return mod;
  var result = {};
  if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
  __setModuleDefault(result, mod);
  return result;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
  function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
  return new (P || (P = Promise))(function (resolve, reject) {
    function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
    function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
    function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
    step((generator = generator.apply(thisArg, _arguments || [])).next());
  });
};
var __asyncValues = (this && this.__asyncValues) || function (o) {
  if (!Symbol.asyncIterator) throw new TypeError("Symbol.asyncIterator is not defined.");
  var m = o[Symbol.asyncIterator], i;
  return m ? m.call(o) : (o = typeof __values === "function" ? __values(o) : o[Symbol.iterator](), i = {}, verb("next"), verb("throw"), verb("return"), i[Symbol.asyncIterator] = function () { return this; }, i);
  function verb(n) { i[n] = o[n] && function (v) { return new Promise(function (resolve, reject) { v = o[n](v), settle(resolve, reject, v.done, v.value); }); }; }
  function settle(resolve, reject, d, v) { Promise.resolve(v).then(function (v) { resolve({ value: v, done: d }); }, reject); }
};
var __importDefault = (this && this.__importDefault) || function (mod) {
  return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MessageBrokerChannel = void 0;
const assert_1 = __importDefault(require("assert"));
const newrelic_1 = __importDefault(require("newrelic"));
const nats_1 = require("nats");
const message_response_1 = require("../models/message-response");
const zlib = __importStar(require("zlib"));
const MQ_TIMEOUT = +process.env.MQ_TIMEOUT || 300000;
class MessageBrokerChannel {
  constructor(channel, channelName) {
    this.channel = channel;
    this.channelName = channelName;
  }
  getTarget(eventType) {
    if (eventType.includes(this.channelName) || eventType.includes('*')) {
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
      console.log('MQ subscribed: %s', target);
      const sub = this.channel.subscribe(target, { queue: process.env.SERVICE_CHANNEL });
      const fn = (sub) => {
        var sub_1, sub_1_1; return __awaiter(this, void 0, void 0, function* () {
          var e_1, _a;
          try {
            for (sub_1 = __asyncValues(sub); sub_1_1 = yield sub_1.next(), !sub_1_1.done;) {
              const m = sub_1_1.value;
              yield newrelic_1.default.startBackgroundTransaction(target, 'Nats response', () => __awaiter(this, void 0, void 0, function* () {
                const transaction = newrelic_1.default.getTransaction();
                let responseMessage;
                try {
                  responseMessage = yield handleFunc(JSON.parse((0, nats_1.StringCodec)().decode(m.data)));
                }
                catch (error) {
                  responseMessage = new message_response_1.MessageError(error, error.code);
                  newrelic_1.default.noticeError(error);
                }
                const archResponse = zlib.deflateSync(JSON.stringify(responseMessage)).toString('binary');
                m.respond((0, nats_1.StringCodec)().encode(archResponse));
                transaction.end();
              }));
            }
          }
          catch (e_1_1) { e_1 = { error: e_1_1 }; }
          finally {
            try {
              if (sub_1_1 && !sub_1_1.done && (_a = sub_1.return)) yield _a.call(sub_1);
            }
            finally { if (e_1) throw e_1.error; }
          }
        });
      };
      try {
        yield fn(sub);
      }
      catch (error) {
        console.error(error.message);
      }
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
      const result = yield newrelic_1.default.startBackgroundTransaction(eventType, 'Nats request', () => __awaiter(this, void 0, void 0, function* () {
        const transaction = newrelic_1.default.getTransaction();
        try {
          let stringPayload;
          switch (typeof payload) {
            case 'string':
              stringPayload = payload;
              break;
            case 'object':
              stringPayload = JSON.stringify(payload);
              break;
            default:
              stringPayload = '{}';
          }
          const msg = yield this.channel.request(eventType, (0, nats_1.StringCodec)().encode(stringPayload), {
            timeout: timeout || MQ_TIMEOUT,
          });
          const unpackedString = zlib.inflateSync(new Buffer((0, nats_1.StringCodec)().decode(msg.data), 'binary')).toString();
          return JSON.parse(unpackedString);
        }
        catch (error) {
          // Nats no subscribe error
          if (error.code === '503') {
            console.warn('No listener for message event type =  %s', eventType);
            return;
          }
          console.error(error.message, error.stack, error);
          newrelic_1.default.noticeError(error);
          throw error;
        }
        finally {
          transaction.end();
        }
      }));
      if (result instanceof Error) {
        throw result;
      }
      return result;
    });
  }
  /**
   * Publish message to all Nats client subscribers
   * @param eventType
   * @param data
   * @param allowError
   */
  publish(eventType, data, allowError = true) {
    newrelic_1.default.startBackgroundTransaction(eventType, 'Nats publish', () => {
      try {
        console.log('MQ publish: %s', eventType);
        const sc = (0, nats_1.JSONCodec)();
        this.channel.publish(eventType, sc.encode(data));
      }
      catch (e) {
        console.error(e.message, e.stack, e);
        if (!allowError) {
          throw e;
        }
      }
    });
  }
  /**
   * Create the Nats MQ connection
   * @param connectionName
   * @returns
   */
  static connect(connectionName) {
    return __awaiter(this, void 0, void 0, function* () {
      (0, assert_1.default)(process.env.MQ_ADDRESS, 'Missing MQ_ADDRESS environment variable');
      return (0, nats_1.connect)({
        servers: [process.env.MQ_ADDRESS],
        name: connectionName,
        reconnectDelayHandler: () => 2000,
        maxReconnectAttempts: -1 // reconnect forever
      });
    });
  }
  ;
}
exports.MessageBrokerChannel = MessageBrokerChannel;
//# sourceMappingURL=message-broker-channel.js.map