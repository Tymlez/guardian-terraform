"use strict";
var __decorate =
  (this && this.__decorate) ||
  function (decorators, target, key, desc) {
    var c = arguments.length,
      r =
        c < 3
          ? target
          : desc === null
          ? (desc = Object.getOwnPropertyDescriptor(target, key))
          : desc,
      d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function")
      r = Reflect.decorate(decorators, target, key, desc);
    else
      for (var i = decorators.length - 1; i >= 0; i--)
        if ((d = decorators[i]))
          r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
  };
var __metadata =
  (this && this.__metadata) ||
  function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function")
      return Reflect.metadata(k, v);
  };
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.DataBaseHelper = exports.COMMON_CONNECTION_CONFIG = void 0;
const core_1 = require("@mikro-orm/core");
const mongodb_1 = require("@mikro-orm/mongodb");
const db_naming_strategy_1 = require("./db-naming-strategy");
/**
 * Common connection config
 */
exports.COMMON_CONNECTION_CONFIG = {
  type: "mongo",
  namingStrategy: db_naming_strategy_1.DataBaseNamingStrategy,
  // dbName: (process.env.ENV || (process.env.HEDERA_NET !== process.env.PREUSED_HEDERA_NET)) ?
  //     `${process.env.ENV}_${process.env.HEDERA_NET}_${process.env.DB_DATABASE}` :
  //     process.env.DB_DATABASE,
  dbName: process.env.DB_DATABASE,
  clientUrl: `mongodb://${process.env.DB_HOST}`,
  entities: ["dist/entity/*.js"],
};
/**
 * Database helper
 */
class DataBaseHelper {
  constructor(entityClass) {
    this.entityClass = entityClass;
    if (!DataBaseHelper.orm) {
      throw new Error("ORM is not initialized");
    }
    this._em = DataBaseHelper.orm.em;
  }
  /**
   * Set ORM
   */
  static set orm(orm) {
    DataBaseHelper._orm = orm;
  }
  /**
   * Get ORM
   */
  static get orm() {
    return DataBaseHelper._orm;
  }
  /**
   * Set GridFS
   */
  static set gridFS(gridFS) {
    DataBaseHelper._gridFS = gridFS;
  }
  /**
   * Get GridFS
   */
  static get gridFS() {
    return DataBaseHelper._gridFS;
  }
  /**
   * Delete entities by filters
   * @param filters filters
   * @returns Count
   */
  delete(filters) {
    return __awaiter(this, void 0, void 0, function* () {
      return yield this._em.nativeDelete(this.entityClass, filters);
    });
  }
  /**
   * Remove entities or entity
   * @param entity Entities or entity
   */
  remove(entity) {
    return __awaiter(this, void 0, void 0, function* () {
      if (Array.isArray(entity)) {
        for (const element of entity) {
          yield this._em.removeAndFlush(element);
        }
      } else {
        yield this._em.removeAndFlush(entity);
      }
    });
  }
  create(entity) {
    if (Array.isArray(entity)) {
      const arrResult = [];
      for (const item of entity) {
        arrResult.push(this.create(item));
      }
      return arrResult;
    }
    if (!entity._id) {
      entity._id = new mongodb_1.ObjectId(mongodb_1.ObjectId.generate());
    }
    return this._em.fork().create(this.entityClass, entity);
  }
  /**
   * Aggregate
   * @param pipeline Pipeline
   * @returns Result
   */
  aggregate(pipeline) {
    var _a, e_1, _b, _c;
    return __awaiter(this, void 0, void 0, function* () {
      const aggregateEntities = yield this._em.aggregate(
        this.entityClass,
        pipeline
      );
      for (const entity of aggregateEntities) {
        for (const systemFileField of DataBaseHelper._systemFileFields) {
          if (Object.keys(entity).includes(systemFileField)) {
            const fileStream = DataBaseHelper.gridFS.openDownloadStream(
              entity[systemFileField]
            );
            const bufferArray = [];
            try {
              for (
                var _d = true,
                  fileStream_1 = ((e_1 = void 0), __asyncValues(fileStream)),
                  fileStream_1_1;
                (fileStream_1_1 = yield fileStream_1.next()),
                  (_a = fileStream_1_1.done),
                  !_a;

              ) {
                _c = fileStream_1_1.value;
                _d = false;
                try {
                  const data = _c;
                  bufferArray.push(data);
                } finally {
                  _d = true;
                }
              }
            } catch (e_1_1) {
              e_1 = { error: e_1_1 };
            } finally {
              try {
                if (!_d && !_a && (_b = fileStream_1.return))
                  yield _b.call(fileStream_1);
              } finally {
                if (e_1) throw e_1.error;
              }
            }
            const buffer = Buffer.concat(bufferArray);
            entity[systemFileField.replace("FileId", "")] = JSON.parse(
              buffer.toString()
            );
          }
        }
      }
      return aggregateEntities;
    });
  }
  /**
   * Find and count
   * @param filters Filters
   * @param options Options
   * @returns Entities and count
   */
  findAndCount(filters, options) {
    return __awaiter(this, void 0, void 0, function* () {
      return yield this._em.findAndCount(
        this.entityClass,
        (filters === null || filters === void 0 ? void 0 : filters.where) ||
          filters,
        options
      );
    });
  }
  /**
   * Count entities
   * @param filters Filters
   * @param options Options
   * @returns Count
   */
  count(filters, options) {
    return __awaiter(this, void 0, void 0, function* () {
      return yield this._em.count(
        this.entityClass,
        (filters === null || filters === void 0 ? void 0 : filters.where) ||
          filters,
        options
      );
    });
  }
  /**
   * Find entities
   * @param filters Filters
   * @param options Options
   * @returns Entities
   */
  find(filters, options) {
    return __awaiter(this, void 0, void 0, function* () {
      return yield this._em
        .getRepository(this.entityClass)
        .find(
          (filters === null || filters === void 0 ? void 0 : filters.where) ||
            filters ||
            {},
          options
        );
    });
  }
  /**
   * Find all entities
   * @param options Options
   * @returns Entities
   */
  findAll(options) {
    return __awaiter(this, void 0, void 0, function* () {
      return yield this._em.getRepository(this.entityClass).findAll(options);
    });
  }
  /**
   * Find entity
   * @param filters Filters
   * @param options Options
   * @returns Entity
   */
  findOne(filter, options = {}) {
    return __awaiter(this, void 0, void 0, function* () {
      return yield this._em
        .getRepository(this.entityClass)
        .findOne(
          (filter === null || filter === void 0 ? void 0 : filter.where) ||
            filter,
          options
        );
    });
  }
  save(entity, filter) {
    return __awaiter(this, void 0, void 0, function* () {
      if (Array.isArray(entity)) {
        const result = [];
        for (const item of entity) {
          result.push(yield this.save(item));
        }
        return result;
      }
      const repository = this._em.getRepository(this.entityClass);
      if (!entity.id && !entity._id && !filter) {
        const e = repository.create(Object.assign({}, entity));
        yield repository.persistAndFlush(e);
        return e;
      }
      let entityToUpdateOrCreate = yield repository.findOne(
        (filter === null || filter === void 0 ? void 0 : filter.where) ||
          filter ||
          entity.id ||
          entity._id
      );
      if (entityToUpdateOrCreate) {
        DataBaseHelper._systemFileFields.forEach((systemFileField) => {
          if (entity[systemFileField]) {
            entity[systemFileField] = entityToUpdateOrCreate[systemFileField];
          }
        });
        (0, core_1.wrap)(entityToUpdateOrCreate).assign(
          Object.assign(Object.assign({}, entity), { updateDate: new Date() }),
          { mergeObjects: false }
        );
      } else {
        entityToUpdateOrCreate = repository.create(Object.assign({}, entity));
        yield repository.persist(entityToUpdateOrCreate);
      }
      yield repository.flush();
      return entityToUpdateOrCreate;
    });
  }
  update(entity, filter) {
    return __awaiter(this, void 0, void 0, function* () {
      if (Array.isArray(entity)) {
        const result = [];
        for (const item of entity) {
          result.push(yield this.update(item));
        }
        return result;
      }
      if (!entity.id && !entity._id && !filter) {
        return;
      }
      const repository = this._em.getRepository(this.entityClass);
      const entitiesToUpdate = yield repository.find(
        (filter === null || filter === void 0 ? void 0 : filter.where) ||
          filter ||
          entity.id ||
          entity._id
      );
      for (const entityToUpdate of entitiesToUpdate) {
        DataBaseHelper._systemFileFields.forEach((systemFileField) => {
          if (entity[systemFileField]) {
            entity[systemFileField] = entityToUpdate[systemFileField];
          }
        });
        (0, core_1.wrap)(entityToUpdate).assign(
          Object.assign(Object.assign({}, entity), { updateDate: new Date() }),
          { mergeObjects: false }
        );
      }
      yield repository.flush();
      return entitiesToUpdate.length === 1
        ? entitiesToUpdate[0]
        : entitiesToUpdate;
    });
  }
}
/**
 * System fields
 */
DataBaseHelper._systemFileFields = [
  "documentFileId",
  "contextFileId",
  "configFileId",
];
__decorate(
  [
    (0, core_1.UseRequestContext)(() => DataBaseHelper.orm),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise),
  ],
  DataBaseHelper.prototype,
  "delete",
  null
);
__decorate(
  [
    (0, core_1.UseRequestContext)(() => DataBaseHelper.orm),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise),
  ],
  DataBaseHelper.prototype,
  "remove",
  null
);
__decorate(
  [
    (0, core_1.UseRequestContext)(() => DataBaseHelper.orm),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Array]),
    __metadata("design:returntype", Promise),
  ],
  DataBaseHelper.prototype,
  "aggregate",
  null
);
__decorate(
  [
    (0, core_1.UseRequestContext)(() => DataBaseHelper.orm),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise),
  ],
  DataBaseHelper.prototype,
  "findAndCount",
  null
);
__decorate(
  [
    (0, core_1.UseRequestContext)(() => DataBaseHelper.orm),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise),
  ],
  DataBaseHelper.prototype,
  "count",
  null
);
__decorate(
  [
    (0, core_1.UseRequestContext)(() => DataBaseHelper.orm),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise),
  ],
  DataBaseHelper.prototype,
  "find",
  null
);
__decorate(
  [
    (0, core_1.UseRequestContext)(() => DataBaseHelper.orm),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise),
  ],
  DataBaseHelper.prototype,
  "findAll",
  null
);
__decorate(
  [
    (0, core_1.UseRequestContext)(() => DataBaseHelper.orm),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise),
  ],
  DataBaseHelper.prototype,
  "findOne",
  null
);
__decorate(
  [
    (0, core_1.UseRequestContext)(() => DataBaseHelper.orm),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise),
  ],
  DataBaseHelper.prototype,
  "save",
  null
);
__decorate(
  [
    (0, core_1.UseRequestContext)(() => DataBaseHelper.orm),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise),
  ],
  DataBaseHelper.prototype,
  "update",
  null
);
exports.DataBaseHelper = DataBaseHelper;
