"use strict";
console.log(
  "This is TopicMessageSubmitTransaction.cjs overwritten with maxChunks =100"
);
Object.defineProperty(exports, "__esModule", {
  value: true,
});
exports.default = void 0;
var _Transaction = _interopRequireWildcard(
  require("../transaction/Transaction.cjs")
);
var _TopicId = _interopRequireDefault(require("./TopicId.cjs"));
var utf8 = _interopRequireWildcard(require("../encoding/utf8.cjs"));
var _TransactionId = _interopRequireDefault(
  require("../transaction/TransactionId.cjs")
);
var _Timestamp = _interopRequireDefault(require("../Timestamp.cjs"));
var util = _interopRequireWildcard(require("../util.cjs"));
function _interopRequireDefault(obj) {
  return obj && obj.__esModule ? obj : { default: obj };
}
function _getRequireWildcardCache(nodeInterop) {
  if (typeof WeakMap !== "function") return null;
  var cacheBabelInterop = new WeakMap();
  var cacheNodeInterop = new WeakMap();
  return (_getRequireWildcardCache = function (nodeInterop) {
    return nodeInterop ? cacheNodeInterop : cacheBabelInterop;
  })(nodeInterop);
}
function _interopRequireWildcard(obj, nodeInterop) {
  if (!nodeInterop && obj && obj.__esModule) {
    return obj;
  }
  if (obj === null || (typeof obj !== "object" && typeof obj !== "function")) {
    return { default: obj };
  }
  var cache = _getRequireWildcardCache(nodeInterop);
  if (cache && cache.has(obj)) {
    return cache.get(obj);
  }
  var newObj = {};
  var hasPropertyDescriptor =
    Object.defineProperty && Object.getOwnPropertyDescriptor;
  for (var key in obj) {
    if (key !== "default" && Object.prototype.hasOwnProperty.call(obj, key)) {
      var desc = hasPropertyDescriptor
        ? Object.getOwnPropertyDescriptor(obj, key)
        : null;
      if (desc && (desc.get || desc.set)) {
        Object.defineProperty(newObj, key, desc);
      } else {
        newObj[key] = obj[key];
      }
    }
  }
  newObj.default = obj;
  if (cache) {
    cache.set(obj, newObj);
  }
  return newObj;
}
/*-
 * ‌
 * Hedera JavaScript SDK
 * ​
 * Copyright (C) 2020 - 2022 Hedera Hashgraph, LLC
 * ​
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ‍
 */

/**
 * @namespace proto
 * @typedef {import("@hashgraph/proto").proto.IConsensusSubmitMessageTransactionBody} HashgraphProto.proto.IConsensusSubmitMessageTransactionBody
 * @typedef {import("@hashgraph/proto").proto.ITransaction} HashgraphProto.proto.ITransaction
 * @typedef {import("@hashgraph/proto").proto.ISignedTransaction} HashgraphProto.proto.ISignedTransaction
 * @typedef {import("@hashgraph/proto").proto.TransactionBody} HashgraphProto.proto.TransactionBody
 * @typedef {import("@hashgraph/proto").proto.ITransactionBody} HashgraphProto.proto.ITransactionBody
 * @typedef {import("@hashgraph/proto").proto.ITransactionResponse} HashgraphProto.proto.ITransactionResponse
 * @typedef {import("@hashgraph/proto").proto.IConsensusMessageChunkInfo} HashgraphProto.proto.IConsensusMessageChunkInfo
 */

/**
 * @typedef {import("../channel/Channel.js").default} Channel
 * @typedef {import("../account/AccountId.js").default} AccountId
 * @typedef {import("../transaction/TransactionResponse.js").default} TransactionResponse
 * @typedef {import("../schedule/ScheduleCreateTransaction.js").default} ScheduleCreateTransaction
 */

class TopicMessageSubmitTransaction extends _Transaction.default {
  /**
   * @param {object} props
   * @param {TopicId | string} [props.topicId]
   * @param {Uint8Array | string} [props.message]
   * @param {number} [props.maxChunks]
   * @param {number} [props.chunkSize]
   */
  constructor(props = {}) {
    super();
    // console.log('TopicMessageSubmitTransaction constructor', props);
    /**
     * @private
     * @type {?TopicId}
     */
    this._topicId = null;
    if (props.topicId != null) {
      this.setTopicId(props.topicId);
    }

    /**
     * @private
     * @type {?Uint8Array}
     */
    this._message = null;
    if (props.message != null) {
      this.setMessage(props.message);
    }

    /**
     * @private
     * @type {number}
     */
    this._maxChunks = 100;

    /**
     * @private
     * @type {number}
     */
    this._chunkSize = _Transaction.CHUNK_SIZE;
    if (props.maxChunks != null) {
      this.setMaxChunks(props.maxChunks);
    }
    if (props.chunkSize != null) {
      this.setChunkSize(props.chunkSize);
    }
    /** @type {HashgraphProto.proto.IConsensusMessageChunkInfo | null} */
    this._chunkInfo = null;
  }

  /**
   * @internal
   * @param {HashgraphProto.proto.ITransaction[]} transactions
   * @param {HashgraphProto.proto.ISignedTransaction[]} signedTransactions
   * @param {TransactionId[]} transactionIds
   * @param {AccountId[]} nodeIds
   * @param {HashgraphProto.proto.ITransactionBody[]} bodies
   * @returns {TopicMessageSubmitTransaction}
   */
  static _fromProtobuf(
    transactions,
    signedTransactions,
    transactionIds,
    nodeIds,
    bodies
  ) {
    const body = bodies[0];
    const message =
      /** @type {HashgraphProto.proto.IConsensusSubmitMessageTransactionBody} */
      body.consensusSubmitMessage;
    return _Transaction.default._fromProtobufTransactions(
      new TopicMessageSubmitTransaction({
        topicId:
          message.topicID != null
            ? _TopicId.default._fromProtobuf(message.topicID)
            : undefined,
        message: message.message != null ? message.message : undefined,
      }),
      transactions,
      signedTransactions,
      transactionIds,
      nodeIds,
      bodies
    );
  }

  /**
   * @returns {?TopicId}
   */
  get topicId() {
    return this._topicId;
  }

  /**
   * @param {TopicId | string} topicId
   * @returns {this}
   */
  setTopicId(topicId) {
    this._requireNotFrozen();
    this._topicId =
      typeof topicId === "string"
        ? _TopicId.default.fromString(topicId)
        : topicId.clone();
    return this;
  }

  /**
   * @deprecated  - Use `getMessage()` instead
   * @returns {?Uint8Array}
   */
  get message() {
    return this._message;
  }

  /**
   * @returns {?Uint8Array}
   */
  getMessage() {
    return this._message;
  }

  /**
   * @param {string | Uint8Array} message
   * @returns {this}
   */
  setMessage(message) {
    this._requireNotFrozen();
    message = util.requireStringOrUint8Array(message);
    this._message =
      message instanceof Uint8Array ? message : utf8.encode(message);
    return this;
  }

  /**
   * @deprecated  - Use `getMaxChunks()` instead
   * @returns {?number}
   */
  get maxChunks() {
    return this._maxChunks;
  }

  /**
   * @returns {?number}
   */
  getMaxChunks() {
    return this._maxChunks;
  }

  /**
   * @param {number} maxChunks
   * @returns {this}
   */
  setMaxChunks(maxChunks) {
    console.log("set max chunk", maxChunks);
    this._requireNotFrozen();
    this._maxChunks = maxChunks;
    return this;
  }

  /**
   * @deprecated  - Use `getChunkSize()` instead
   * @returns {?number}
   */
  get chunkSize() {
    return this._chunkSize;
  }

  /**
   * @returns {?number}
   */
  getChunkSize() {
    return this._chunkSize;
  }

  /**
   * @param {number} chunkSize
   * @returns {this}
   */
  setChunkSize(chunkSize) {
    this._chunkSize = chunkSize;
    return this;
  }

  /**
   * Freeze this transaction from further modification to prepare for
   * signing or serialization.
   *
   * Will use the `Client`, if available, to generate a default Transaction ID and select 1/3
   * nodes to prepare this transaction for.
   *
   * @param {?import("../client/Client.js").default<Channel, *>} client
   * @returns {this}
   */
  freezeWith(client) {
    super.freezeWith(client);
    if (this._message == null) {
      return this;
    }
    const chunks = Math.floor(
      (this._message.length + (this._chunkSize - 1)) / this._chunkSize
    );
    if (chunks > this._maxChunks) {
      throw new Error(
        `Message with size ${this._message.length} too long for ${this._maxChunks} chunks, chunk size = ${this._chunkSize}`
      );
    }
    const initialTransactionId = this._getTransactionId()._toProtobuf();
    let nextTransactionId = this._getTransactionId();

    // Hack around the locked list. Should refactor a bit to remove such code
    this._transactionIds.locked = false;
    this._transactions.clear();
    this._transactionIds.clear();
    this._signedTransactions.clear();
    for (let chunk = 0; chunk < chunks; chunk++) {
      this._chunkInfo = {
        initialTransactionID: initialTransactionId,
        total: chunks,
        number: chunk + 1,
      };
      this._transactionIds.push(nextTransactionId);
      this._transactionIds.advance();
      for (const nodeAccountId of this._nodeAccountIds.list) {
        this._signedTransactions.push(
          this._makeSignedTransaction(nodeAccountId)
        );
      }
      nextTransactionId = new _TransactionId.default(
        /** @type {AccountId} */ nextTransactionId.accountId,
        new _Timestamp.default(
          /** @type {Timestamp} */ nextTransactionId.validStart.seconds,
          /** @type {Timestamp} */ nextTransactionId.validStart.nanos.add(1)
        )
      );
    }
    this._transactionIds.advance();
    this._chunkInfo = null;
    return this;
  }

  /**
   * @returns {ScheduleCreateTransaction}
   */
  schedule() {
    this._requireNotFrozen();
    if (this._message != null && this._message.length > this._chunkSize) {
      throw new Error(
        `cannot schedule \`TopicMessageSubmitTransaction\` with message over ${this._chunkSize} bytes`
      );
    }
    return super.schedule();
  }

  /**
   * @param {import("../client/Client.js").default<Channel, *>} client
   * @param {number=} requestTimeout
   * @returns {Promise<TransactionResponse>}
   */
  async execute(client, requestTimeout) {
    return (await this.executeAll(client, requestTimeout))[0];
  }

  /**
   * @param {import("../client/Client.js").default<Channel, *>} client
   * @param {number=} requestTimeout
   * @returns {Promise<TransactionResponse[]>}
   */
  async executeAll(client, requestTimeout) {
    if (!super._isFrozen()) {
      this.freezeWith(client);
    }

    // on execute, sign each transaction with the operator, if present
    // and we are signing a transaction that used the default transaction ID

    const transactionId = this._getTransactionId();
    const operatorAccountId = client.operatorAccountId;
    if (
      operatorAccountId != null &&
      operatorAccountId.equals(/** @type {AccountId} */ transactionId.accountId)
    ) {
      await super.signWithOperator(client);
    }
    const responses = [];
    let remainingTimeout = requestTimeout;
    for (let i = 0; i < this._transactionIds.length; i++) {
      const startTimestamp = Date.now();
      responses.push(await super.execute(client, remainingTimeout));
      if (remainingTimeout != null) {
        remainingTimeout = Date.now() - startTimestamp;
      }
    }
    return responses;
  }

  /**
   * @override
   * @internal
   * @param {Channel} channel
   * @param {HashgraphProto.proto.ITransaction} request
   * @returns {Promise<HashgraphProto.proto.ITransactionResponse>}
   */
  _execute(channel, request) {
    return channel.consensus.submitMessage(request);
  }

  /**
   * @override
   * @protected
   * @returns {NonNullable<HashgraphProto.proto.TransactionBody["data"]>}
   */
  _getTransactionDataCase() {
    return "consensusSubmitMessage";
  }

  /**
   * @override
   * @protected
   * @returns {HashgraphProto.proto.IConsensusSubmitMessageTransactionBody}
   */
  _makeTransactionData() {
    if (this._chunkInfo != null && this._message != null) {
      const num = /** @type {number} */ this._chunkInfo.number;
      const startIndex = (num - 1) * this._chunkSize;
      let endIndex = startIndex + this._chunkSize;
      if (endIndex > this._message.length) {
        endIndex = this._message.length;
      }
      return {
        topicID: this._topicId != null ? this._topicId._toProtobuf() : null,
        message: this._message.slice(startIndex, endIndex),
        chunkInfo: this._chunkInfo,
      };
    } else {
      return {
        topicID: this._topicId != null ? this._topicId._toProtobuf() : null,
        message: this._message,
      };
    }
  }

  /**
   * @returns {string}
   */
  _getLogId() {
    const timestamp =
      /** @type {import("../Timestamp.js").default} */
      this._transactionIds.current.validStart;
    return `TopicMessageSubmitTransaction:${timestamp.toString()}`;
  }
}
exports.default = TopicMessageSubmitTransaction;
_Transaction.TRANSACTION_REGISTRY.set(
  "consensusSubmitMessage",
  // eslint-disable-next-line @typescript-eslint/unbound-method
  TopicMessageSubmitTransaction._fromProtobuf
);
