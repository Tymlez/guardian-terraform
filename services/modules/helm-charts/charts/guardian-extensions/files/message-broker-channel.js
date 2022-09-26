"use strict";
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
    function settle(resolve, reject, d, v) { Promise.resolve(v).then(function(v) { resolve({ value: v, done: d }); }, reject); }
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MessageBrokerChannel = void 0;
const assert_1 = __importDefault(require("assert"));
const nats_1 = require("nats");
const newrelic_1 = __importDefault(require("newrelic"));
const message_response_1 = require("../models/message-response");
const interfaces_1 = require("@guardian/interfaces");
const MQ_TIMEOUT = 300000;
const reqMap = new Map();
/**
 * Message broker channel
 */
class MessageBrokerChannel {
    constructor(channel, channelName) {
        this.channel = channel;
        this.channelName = channelName;
        const fn = (_sub) => { var _sub_1, _sub_1_1; return __awaiter(this, void 0, void 0, function* () {
            var e_1, _a;
            try {

                for (_sub_1 = __asyncValues(_sub); _sub_1_1 = yield _sub_1.next(), !_sub_1_1.done;) {
                    const m = _sub_1_1.value;
                    if (!m.headers) {
                        console.error('No headers');
                        return;
                    }
                    const messageId = m.headers.get('messageId');
                    if (reqMap.has(messageId)) {
                        const dataObj = JSON.parse((0, nats_1.StringCodec)().decode(m.data));
                        const func = reqMap.get(messageId);
                        func(dataObj);
                    }
                }
            }
            catch (e_1_1) { e_1 = { error: e_1_1 }; }
            finally {
                try {
                    if (_sub_1_1 && !_sub_1_1.done && (_a = _sub_1.return)) yield _a.call(_sub_1);
                }
                finally { if (e_1) throw e_1.error; }
            }
        }); };
        fn(this.channel.subscribe('response-message', { queue: process.env.SERVICE_CHANNEL })).then();
    }
    /**
     * Get target
     * @param eventType
     * @private
     */
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
            const fn = (_sub) => { var _sub_2, _sub_2_1; return __awaiter(this, void 0, void 0, function* () {
                var e_2, _a;
                try {
                    for (_sub_2 = __asyncValues(_sub); _sub_2_1 = yield _sub_2.next(), !_sub_2_1.done;) {
                        const m = _sub_2_1.value;
                        const messageId = m.headers.get('messageId');
                        let responseMessage;
                        yield newrelic_1.default.startBackgroundTransaction(target, 'Nats response', () => __awaiter(this, void 0, void 0, function* () {
                          const transaction = newrelic_1.default.getTransaction();
                          try {
                              const payload = JSON.parse((0, nats_1.StringCodec)().decode(m.data));
                              responseMessage = yield handleFunc(payload);
                          }
                          catch (error) {
                              newrelic_1.default.noticeError(error);
                              responseMessage = new message_response_1.MessageError(error, error.code);
                          }
                          const head = (0, nats_1.headers)();
                          head.append('messageId', messageId);
                          this.channel.publish('response-message', (0, nats_1.StringCodec)().encode(JSON.stringify(responseMessage)), { headers: head });
                          m.respond(new Uint8Array(0));
                          transaction.end();
                      }))
                    }
                }
                catch (e_2_1) { e_2 = { error: e_2_1 }; }
                finally {
                    try {
                        if (_sub_2_1 && !_sub_2_1.done && (_a = _sub_2.return)) yield _a.call(_sub_2);
                    }
                    finally { if (e_2) throw e_2.error; }
                }
            }); };
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
      __awaiter(this, void 0, void 0, function* () {
        const result = yield newrelic_1.default.startBackgroundTransaction(eventType, 'Nats request', () => __awaiter(this, void 0, void 0, function* () {
          const transaction = newrelic_1.default.getTransaction();

          try {
              const messageId = (0, interfaces_1.GenerateUUIDv4)() + '-' +  eventType;
              const head = (0, nats_1.headers)();
              head.append('messageId', messageId);
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
              return new Promise((resolve, reject) => {
                  reqMap.set(messageId, (data) => {
                      resolve(data);
                      reqMap.delete(messageId);
                  });
                  this.channel.request(eventType, (0, nats_1.StringCodec)().encode(stringPayload), {
                      timeout: timeout || MQ_TIMEOUT,
                      headers: head
                  }).then(() => { return; }, (error) => {
                      reqMap.delete(messageId);
                      // Nats no subscribe error
                      if (error.code === '503') {
                          console.warn('No listener for message event type =  %s', eventType);
                          resolve(null);
                          return;
                      }
                      console.error(error.message, error.stack, error);
                      reject(error);
                  });
              });
          }
          catch (error) {
              return new Promise((resolve, reject) => {
                  // Nats no subscribe error
                  if (error.code === '503') {
                      console.warn('No listener for message event type =  %s', eventType);
                      resolve(null);
                      return;
                  }
                  console.error(error.message, error.stack, error);
                  newrelic_1.default.noticeError(error);
                  reject(error);
              });
          }
          finally {
            transaction.end()
          }
        }))
     })
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
            const messageId = (0, interfaces_1.GenerateUUIDv4)();
            const head = (0, nats_1.headers)();
            head.append('messageId', messageId);
            const sc = (0, nats_1.JSONCodec)();
            this.channel.publish(eventType, sc.encode(data), { headers: head });
        }
        catch (e) {
            console.error(e.message, e.stack, e);
            if (!allowError) {
                throw e;
            }
        }
      })
    }
    /**
     * Subscribe for subject
     * @param subj
     * @param callback
     */
    subscribe(subj, callback) {
        const sub = this.channel.subscribe(subj, { queue: process.env.SERVICE_CHANNEL });
        const fn = (_sub) => { var _sub_3, _sub_3_1; return __awaiter(this, void 0, void 0, function* () {
            var e_3, _a;
            try {
                for (_sub_3 = __asyncValues(_sub); _sub_3_1 = yield _sub_3.next(), !_sub_3_1.done;) {
                    const m = _sub_3_1.value;
                    const dataObj = JSON.parse((0, nats_1.StringCodec)().decode(m.data));
                    callback(dataObj);
                }
            }
            catch (e_3_1) { e_3 = { error: e_3_1 }; }
            finally {
                try {
                    if (_sub_3_1 && !_sub_3_1.done && (_a = _sub_3.return)) yield _a.call(_sub_3);
                }
                finally { if (e_3) throw e_3.error; }
            }
        }); };
        fn(sub);
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