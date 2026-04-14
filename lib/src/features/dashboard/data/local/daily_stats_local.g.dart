// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stats_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyStatsLocalCollection on Isar {
  IsarCollection<DailyStatsLocal> get dailyStatsLocals => this.collection();
}

const DailyStatsLocalSchema = CollectionSchema(
  name: r'DailyStatsLocal',
  id: -1073310328626852096,
  properties: {
    r'activeCalories': PropertySchema(
      id: 0,
      name: r'activeCalories',
      type: IsarType.long,
    ),
    r'caloriesConsumed': PropertySchema(
      id: 1,
      name: r'caloriesConsumed',
      type: IsarType.long,
    ),
    r'carbs': PropertySchema(
      id: 2,
      name: r'carbs',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 3,
      name: r'date',
      type: IsarType.string,
    ),
    r'deepSleepMinutes': PropertySchema(
      id: 4,
      name: r'deepSleepMinutes',
      type: IsarType.long,
    ),
    r'fat': PropertySchema(
      id: 5,
      name: r'fat',
      type: IsarType.long,
    ),
    r'heartRateAvg': PropertySchema(
      id: 6,
      name: r'heartRateAvg',
      type: IsarType.long,
    ),
    r'hydrationMl': PropertySchema(
      id: 7,
      name: r'hydrationMl',
      type: IsarType.long,
    ),
    r'protein': PropertySchema(
      id: 8,
      name: r'protein',
      type: IsarType.long,
    ),
    r'spO2Avg': PropertySchema(
      id: 9,
      name: r'spO2Avg',
      type: IsarType.long,
    ),
    r'steps': PropertySchema(
      id: 10,
      name: r'steps',
      type: IsarType.long,
    ),
    r'totalWorkouts': PropertySchema(
      id: 11,
      name: r'totalWorkouts',
      type: IsarType.long,
    )
  },
  estimateSize: _dailyStatsLocalEstimateSize,
  serialize: _dailyStatsLocalSerialize,
  deserialize: _dailyStatsLocalDeserialize,
  deserializeProp: _dailyStatsLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyStatsLocalGetId,
  getLinks: _dailyStatsLocalGetLinks,
  attach: _dailyStatsLocalAttach,
  version: '3.1.0+1',
);

int _dailyStatsLocalEstimateSize(
  DailyStatsLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.date.length * 3;
  return bytesCount;
}

void _dailyStatsLocalSerialize(
  DailyStatsLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.activeCalories);
  writer.writeLong(offsets[1], object.caloriesConsumed);
  writer.writeLong(offsets[2], object.carbs);
  writer.writeString(offsets[3], object.date);
  writer.writeLong(offsets[4], object.deepSleepMinutes);
  writer.writeLong(offsets[5], object.fat);
  writer.writeLong(offsets[6], object.heartRateAvg);
  writer.writeLong(offsets[7], object.hydrationMl);
  writer.writeLong(offsets[8], object.protein);
  writer.writeLong(offsets[9], object.spO2Avg);
  writer.writeLong(offsets[10], object.steps);
  writer.writeLong(offsets[11], object.totalWorkouts);
}

DailyStatsLocal _dailyStatsLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyStatsLocal();
  object.activeCalories = reader.readLong(offsets[0]);
  object.caloriesConsumed = reader.readLong(offsets[1]);
  object.carbs = reader.readLong(offsets[2]);
  object.date = reader.readString(offsets[3]);
  object.deepSleepMinutes = reader.readLongOrNull(offsets[4]);
  object.fat = reader.readLong(offsets[5]);
  object.heartRateAvg = reader.readLongOrNull(offsets[6]);
  object.hydrationMl = reader.readLong(offsets[7]);
  object.id = id;
  object.protein = reader.readLong(offsets[8]);
  object.spO2Avg = reader.readLongOrNull(offsets[9]);
  object.steps = reader.readLong(offsets[10]);
  object.totalWorkouts = reader.readLong(offsets[11]);
  return object;
}

P _dailyStatsLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyStatsLocalGetId(DailyStatsLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyStatsLocalGetLinks(DailyStatsLocal object) {
  return [];
}

void _dailyStatsLocalAttach(
    IsarCollection<dynamic> col, Id id, DailyStatsLocal object) {
  object.id = id;
}

extension DailyStatsLocalByIndex on IsarCollection<DailyStatsLocal> {
  Future<DailyStatsLocal?> getByDate(String date) {
    return getByIndex(r'date', [date]);
  }

  DailyStatsLocal? getByDateSync(String date) {
    return getByIndexSync(r'date', [date]);
  }

  Future<bool> deleteByDate(String date) {
    return deleteByIndex(r'date', [date]);
  }

  bool deleteByDateSync(String date) {
    return deleteByIndexSync(r'date', [date]);
  }

  Future<List<DailyStatsLocal?>> getAllByDate(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndex(r'date', values);
  }

  List<DailyStatsLocal?> getAllByDateSync(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'date', values);
  }

  Future<int> deleteAllByDate(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'date', values);
  }

  int deleteAllByDateSync(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'date', values);
  }

  Future<Id> putByDate(DailyStatsLocal object) {
    return putByIndex(r'date', object);
  }

  Id putByDateSync(DailyStatsLocal object, {bool saveLinks = true}) {
    return putByIndexSync(r'date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDate(List<DailyStatsLocal> objects) {
    return putAllByIndex(r'date', objects);
  }

  List<Id> putAllByDateSync(List<DailyStatsLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'date', objects, saveLinks: saveLinks);
  }
}

extension DailyStatsLocalQueryWhereSort
    on QueryBuilder<DailyStatsLocal, DailyStatsLocal, QWhere> {
  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DailyStatsLocalQueryWhere
    on QueryBuilder<DailyStatsLocal, DailyStatsLocal, QWhereClause> {
  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterWhereClause> dateEqualTo(
      String date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterWhereClause>
      dateNotEqualTo(String date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DailyStatsLocalQueryFilter
    on QueryBuilder<DailyStatsLocal, DailyStatsLocal, QFilterCondition> {
  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      activeCaloriesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeCalories',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      activeCaloriesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeCalories',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      activeCaloriesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeCalories',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      activeCaloriesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeCalories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      caloriesConsumedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caloriesConsumed',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      caloriesConsumedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'caloriesConsumed',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      caloriesConsumedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'caloriesConsumed',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      caloriesConsumedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'caloriesConsumed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      carbsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbs',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      carbsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbs',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      carbsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbs',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      carbsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      dateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      dateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      dateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      dateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      dateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      dateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      dateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      dateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'date',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      deepSleepMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deepSleepMinutes',
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      deepSleepMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deepSleepMinutes',
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      deepSleepMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      deepSleepMinutesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deepSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      deepSleepMinutesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deepSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      deepSleepMinutesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deepSleepMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      fatEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fat',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      fatGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fat',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      fatLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fat',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      fatBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      heartRateAvgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'heartRateAvg',
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      heartRateAvgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'heartRateAvg',
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      heartRateAvgEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heartRateAvg',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      heartRateAvgGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heartRateAvg',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      heartRateAvgLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heartRateAvg',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      heartRateAvgBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heartRateAvg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      hydrationMlEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hydrationMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      hydrationMlGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hydrationMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      hydrationMlLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hydrationMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      hydrationMlBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hydrationMl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      proteinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'protein',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      proteinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'protein',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      proteinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'protein',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      proteinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'protein',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      spO2AvgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'spO2Avg',
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      spO2AvgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'spO2Avg',
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      spO2AvgEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spO2Avg',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      spO2AvgGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spO2Avg',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      spO2AvgLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spO2Avg',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      spO2AvgBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spO2Avg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      stepsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'steps',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      stepsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'steps',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      stepsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'steps',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      stepsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'steps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      totalWorkoutsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalWorkouts',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      totalWorkoutsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalWorkouts',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      totalWorkoutsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalWorkouts',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterFilterCondition>
      totalWorkoutsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalWorkouts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyStatsLocalQueryObject
    on QueryBuilder<DailyStatsLocal, DailyStatsLocal, QFilterCondition> {}

extension DailyStatsLocalQueryLinks
    on QueryBuilder<DailyStatsLocal, DailyStatsLocal, QFilterCondition> {}

extension DailyStatsLocalQuerySortBy
    on QueryBuilder<DailyStatsLocal, DailyStatsLocal, QSortBy> {
  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByActiveCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeCalories', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByActiveCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeCalories', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByCaloriesConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesConsumed', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByCaloriesConsumedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesConsumed', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> sortByCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByDeepSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByDeepSleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> sortByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> sortByFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByHeartRateAvg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartRateAvg', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByHeartRateAvgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartRateAvg', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByHydrationMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hydrationMl', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByHydrationMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hydrationMl', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> sortByProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> sortBySpO2Avg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spO2Avg', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortBySpO2AvgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spO2Avg', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> sortBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByStepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByTotalWorkouts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkouts', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      sortByTotalWorkoutsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkouts', Sort.desc);
    });
  }
}

extension DailyStatsLocalQuerySortThenBy
    on QueryBuilder<DailyStatsLocal, DailyStatsLocal, QSortThenBy> {
  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByActiveCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeCalories', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByActiveCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeCalories', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByCaloriesConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesConsumed', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByCaloriesConsumedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesConsumed', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> thenByCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbs', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByDeepSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByDeepSleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> thenByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> thenByFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByHeartRateAvg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartRateAvg', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByHeartRateAvgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartRateAvg', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByHydrationMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hydrationMl', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByHydrationMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hydrationMl', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> thenByProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protein', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> thenBySpO2Avg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spO2Avg', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenBySpO2AvgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spO2Avg', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy> thenBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByStepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.desc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByTotalWorkouts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkouts', Sort.asc);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QAfterSortBy>
      thenByTotalWorkoutsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkouts', Sort.desc);
    });
  }
}

extension DailyStatsLocalQueryWhereDistinct
    on QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct> {
  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct>
      distinctByActiveCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeCalories');
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct>
      distinctByCaloriesConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caloriesConsumed');
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct> distinctByCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbs');
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct> distinctByDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct>
      distinctByDeepSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deepSleepMinutes');
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct> distinctByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fat');
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct>
      distinctByHeartRateAvg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heartRateAvg');
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct>
      distinctByHydrationMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hydrationMl');
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct>
      distinctByProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'protein');
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct>
      distinctBySpO2Avg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spO2Avg');
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct> distinctBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'steps');
    });
  }

  QueryBuilder<DailyStatsLocal, DailyStatsLocal, QDistinct>
      distinctByTotalWorkouts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalWorkouts');
    });
  }
}

extension DailyStatsLocalQueryProperty
    on QueryBuilder<DailyStatsLocal, DailyStatsLocal, QQueryProperty> {
  QueryBuilder<DailyStatsLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyStatsLocal, int, QQueryOperations>
      activeCaloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeCalories');
    });
  }

  QueryBuilder<DailyStatsLocal, int, QQueryOperations>
      caloriesConsumedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caloriesConsumed');
    });
  }

  QueryBuilder<DailyStatsLocal, int, QQueryOperations> carbsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbs');
    });
  }

  QueryBuilder<DailyStatsLocal, String, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyStatsLocal, int?, QQueryOperations>
      deepSleepMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deepSleepMinutes');
    });
  }

  QueryBuilder<DailyStatsLocal, int, QQueryOperations> fatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fat');
    });
  }

  QueryBuilder<DailyStatsLocal, int?, QQueryOperations> heartRateAvgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heartRateAvg');
    });
  }

  QueryBuilder<DailyStatsLocal, int, QQueryOperations> hydrationMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hydrationMl');
    });
  }

  QueryBuilder<DailyStatsLocal, int, QQueryOperations> proteinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'protein');
    });
  }

  QueryBuilder<DailyStatsLocal, int?, QQueryOperations> spO2AvgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spO2Avg');
    });
  }

  QueryBuilder<DailyStatsLocal, int, QQueryOperations> stepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'steps');
    });
  }

  QueryBuilder<DailyStatsLocal, int, QQueryOperations> totalWorkoutsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalWorkouts');
    });
  }
}
