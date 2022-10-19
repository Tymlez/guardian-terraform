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
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod };
  };
Object.defineProperty(exports, "__esModule", { value: true });
exports.Hashicorp = void 0;
const node_vault_1 = __importDefault(require("node-vault"));
const assert_1 = __importDefault(require("assert"));
const crypto_1 = __importDefault(require("crypto"));
/**
 * HashiCorp vault helper
 */
class Hashicorp {
  /**
   * Logger instance
   * @private
   */
  // private readonly logger: Logger;
  constructor() {
    /**
     * Vault options
     * @private
     */
    this.options = {
      apiVersion: "v1",
      endpoint: process.env.HASHICORP_ADDRESS,
      token: process.env.HASHICORP_TOKEN,
      namespace: process.env.HASHICORP_NAMESPACE,
    };
    (0, assert_1.default)(
      process.env.HASHICORP_ADDRESS,
      "HASHICORP_ADDRESS environment variable is not set"
    );
    (0, assert_1.default)(
      process.env.HASHICORP_TOKEN,
      "HASHICORP_TOKEN environment variable is not set"
    );
    this.vault = (0, node_vault_1.default)(this.options);
    // this.logger = new Logger();
  }
  /**
   * Generate base64 encoded string
   * @param token
   * @param type
   * @param key
   * @private
   */
  generateKeyName(token, type, key) {
    return crypto_1.default
      .createHash("sha256")
      .update(`${token}|${type}|${key}`)
      .digest("hex");
  }
  /**
   * Init vault
   * @private
   */
  init() {
    return __awaiter(this, void 0, void 0, function* () {
      try {
        const { initialized } = yield this.vault.initialized();
        if (!initialized) {
          const { keys, root_token } = yield this.vault.init({
            secret_shares: 1,
            secret_threshold: 1,
          });
          this.vault.token = root_token;
          console.info("Root Token", root_token);
          yield this.vault.unseal({ secret_shares: 1, key: keys[0] });
        }
      } catch (e) {
        console.warn(e.message);
      }
      return this;
    });
  }
  /**
   * Get key from vault
   * @param token
   * @param type
   * @param key
   */
  getKey(token, type, key) {
    return __awaiter(this, void 0, void 0, function* () {
      const result = yield this.vault.read(
        `secret/data/${this.generateKeyName(token, type, key)}`
      );
      return result.data.data.privateKey;
    });
  }
  /**
   * Set key to vault
   * @param token
   * @param type
   * @param key
   * @param value
   */
  setKey(token, type, key, value) {
    return __awaiter(this, void 0, void 0, function* () {
      yield this.vault.write(
        `secret/data/${this.generateKeyName(token, type, key)}`,
        {
          data: {
            privateKey: value,
          },
        }
      );
    });
  }
  /**
   * Get global application key
   * @param type
   */
  getGlobalApplicationKey(type) {
    return __awaiter(this, void 0, void 0, function* () {
      try {
        const result = yield this.vault.read(`secret/data/${type}`);
        return result.data.data.settingKey;
      } catch (e) {
        console.warn(e.message);
        return undefined;
      }
    });
  }
  /**
   * Set global application key
   * @param type
   * @param key
   */
  setGlobalApplicationKey(type, key) {
    return __awaiter(this, void 0, void 0, function* () {
      yield this.vault.write(`secret/data/${type}`, {
        data: {
          settingKey: key,
        },
      });
    });
  }
}
exports.Hashicorp = Hashicorp;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiaGFzaGljb3JwLmpzIiwic291cmNlUm9vdCI6IiIsInNvdXJjZXMiOlsiLi4vLi4vLi4vc3JjL3ZhdWx0cy92YXVsdC1wcm92aWRlcnMvaGFzaGljb3JwLnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7Ozs7Ozs7Ozs7OztBQUFBLDREQUFtQztBQUVuQyxvREFBNEI7QUFDNUIsb0RBQTRCO0FBRTVCOztHQUVHO0FBQ0gsTUFBYSxTQUFTO0lBa0JsQjs7O09BR0c7SUFDSCxtQ0FBbUM7SUFFbkM7UUF2QkE7OztXQUdHO1FBQ2MsWUFBTyxHQUEyQjtZQUMvQyxVQUFVLEVBQUUsSUFBSTtZQUNoQixRQUFRLEVBQUUsT0FBTyxDQUFDLEdBQUcsQ0FBQyxpQkFBaUI7WUFDdkMsS0FBSyxFQUFFLE9BQU8sQ0FBQyxHQUFHLENBQUMsZUFBZTtZQUNsQyxTQUFTLEVBQUUsT0FBTyxDQUFDLEdBQUcsQ0FBQyxtQkFBbUI7U0FDN0MsQ0FBQTtRQWVHLElBQUEsZ0JBQU0sRUFBQyxPQUFPLENBQUMsR0FBRyxDQUFDLGlCQUFpQixFQUFFLG1EQUFtRCxDQUFDLENBQUM7UUFDM0YsSUFBQSxnQkFBTSxFQUFDLE9BQU8sQ0FBQyxHQUFHLENBQUMsZUFBZSxFQUFFLGlEQUFpRCxDQUFDLENBQUM7UUFFdkYsSUFBSSxDQUFDLEtBQUssR0FBRyxJQUFBLG9CQUFTLEVBQUMsSUFBSSxDQUFDLE9BQU8sQ0FBQyxDQUFDO1FBQ3JDLDhCQUE4QjtJQUNsQyxDQUFDO0lBRUQ7Ozs7OztPQU1HO0lBQ0ssZUFBZSxDQUFDLEtBQWEsRUFBRSxJQUFZLEVBQUUsR0FBVztRQUM1RCxPQUFPLGdCQUFNLENBQUMsVUFBVSxDQUFDLFFBQVEsQ0FBQyxDQUFDLE1BQU0sQ0FBQyxHQUFHLEtBQUssSUFBSSxJQUFJLElBQUksR0FBRyxFQUFFLENBQUMsQ0FBQyxNQUFNLENBQUMsS0FBSyxDQUFDLENBQUM7SUFDdkYsQ0FBQztJQUVEOzs7T0FHRztJQUNVLElBQUk7O1lBQ2IsSUFBSTtnQkFDQSxN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
