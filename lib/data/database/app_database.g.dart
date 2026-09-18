// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MilkRecordsTable extends MilkRecords
    with TableInfo<$MilkRecordsTable, MilkRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilkRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storedAtUtcMeta = const VerificationMeta(
    'storedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> storedAtUtc = GeneratedColumn<DateTime>(
    'stored_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneOffsetMinutesMeta =
      const VerificationMeta('timezoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timezoneOffsetMinutes = GeneratedColumn<int>(
    'timezone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMlMeta = const VerificationMeta(
    'amountMl',
  );
  @override
  late final GeneratedColumn<int> amountMl = GeneratedColumn<int>(
    'amount_ml',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('amount_ml > 0'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MilkStorageMode, String>
  storageMode = GeneratedColumn<String>(
    'storage_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MilkStorageMode>($MilkRecordsTable.$converterstorageMode);
  static const VerificationMeta _foodNotesMeta = const VerificationMeta(
    'foodNotes',
  );
  @override
  late final GeneratedColumn<String> foodNotes = GeneratedColumn<String>(
    'food_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MilkStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MilkStatus>($MilkRecordsTable.$converterstatus);
  static const VerificationMeta _bestUseAtUtcMeta = const VerificationMeta(
    'bestUseAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> bestUseAtUtc = GeneratedColumn<DateTime>(
    'best_use_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtUtcMeta = const VerificationMeta(
    'expiresAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAtUtc = GeneratedColumn<DateTime>(
    'expires_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thawStartedAtUtcMeta = const VerificationMeta(
    'thawStartedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> thawStartedAtUtc =
      GeneratedColumn<DateTime>(
        'thaw_started_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _checkedOutAtUtcMeta = const VerificationMeta(
    'checkedOutAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> checkedOutAtUtc =
      GeneratedColumn<DateTime>(
        'checked_out_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _discardedAtUtcMeta = const VerificationMeta(
    'discardedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> discardedAtUtc =
      GeneratedColumn<DateTime>(
        'discarded_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<PrintStatus, String> printStatus =
      GeneratedColumn<String>(
        'print_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PrintStatus>($MilkRecordsTable.$converterprintStatus);
  static const VerificationMeta _lastPrintedAtUtcMeta = const VerificationMeta(
    'lastPrintedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> lastPrintedAtUtc =
      GeneratedColumn<DateTime>(
        'last_printed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _expiryRuleVersionMeta = const VerificationMeta(
    'expiryRuleVersion',
  );
  @override
  late final GeneratedColumn<String> expiryRuleVersion =
      GeneratedColumn<String>(
        'expiry_rule_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storedAtUtc,
    timezoneOffsetMinutes,
    amountMl,
    storageMode,
    foodNotes,
    status,
    bestUseAtUtc,
    expiresAtUtc,
    thawStartedAtUtc,
    checkedOutAtUtc,
    discardedAtUtc,
    printStatus,
    lastPrintedAtUtc,
    expiryRuleVersion,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milk_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MilkRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('stored_at_utc')) {
      context.handle(
        _storedAtUtcMeta,
        storedAtUtc.isAcceptableOrUnknown(
          data['stored_at_utc']!,
          _storedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storedAtUtcMeta);
    }
    if (data.containsKey('timezone_offset_minutes')) {
      context.handle(
        _timezoneOffsetMinutesMeta,
        timezoneOffsetMinutes.isAcceptableOrUnknown(
          data['timezone_offset_minutes']!,
          _timezoneOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timezoneOffsetMinutesMeta);
    }
    if (data.containsKey('amount_ml')) {
      context.handle(
        _amountMlMeta,
        amountMl.isAcceptableOrUnknown(data['amount_ml']!, _amountMlMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMlMeta);
    }
    if (data.containsKey('food_notes')) {
      context.handle(
        _foodNotesMeta,
        foodNotes.isAcceptableOrUnknown(data['food_notes']!, _foodNotesMeta),
      );
    }
    if (data.containsKey('best_use_at_utc')) {
      context.handle(
        _bestUseAtUtcMeta,
        bestUseAtUtc.isAcceptableOrUnknown(
          data['best_use_at_utc']!,
          _bestUseAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('expires_at_utc')) {
      context.handle(
        _expiresAtUtcMeta,
        expiresAtUtc.isAcceptableOrUnknown(
          data['expires_at_utc']!,
          _expiresAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expiresAtUtcMeta);
    }
    if (data.containsKey('thaw_started_at_utc')) {
      context.handle(
        _thawStartedAtUtcMeta,
        thawStartedAtUtc.isAcceptableOrUnknown(
          data['thaw_started_at_utc']!,
          _thawStartedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('checked_out_at_utc')) {
      context.handle(
        _checkedOutAtUtcMeta,
        checkedOutAtUtc.isAcceptableOrUnknown(
          data['checked_out_at_utc']!,
          _checkedOutAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('discarded_at_utc')) {
      context.handle(
        _discardedAtUtcMeta,
        discardedAtUtc.isAcceptableOrUnknown(
          data['discarded_at_utc']!,
          _discardedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_printed_at_utc')) {
      context.handle(
        _lastPrintedAtUtcMeta,
        lastPrintedAtUtc.isAcceptableOrUnknown(
          data['last_printed_at_utc']!,
          _lastPrintedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('expiry_rule_version')) {
      context.handle(
        _expiryRuleVersionMeta,
        expiryRuleVersion.isAcceptableOrUnknown(
          data['expiry_rule_version']!,
          _expiryRuleVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expiryRuleVersionMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MilkRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MilkRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}stored_at_utc'],
      )!,
      timezoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timezone_offset_minutes'],
      )!,
      amountMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_ml'],
      )!,
      storageMode: $MilkRecordsTable.$converterstorageMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}storage_mode'],
        )!,
      ),
      foodNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_notes'],
      )!,
      status: $MilkRecordsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      bestUseAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}best_use_at_utc'],
      ),
      expiresAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at_utc'],
      )!,
      thawStartedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}thaw_started_at_utc'],
      ),
      checkedOutAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_out_at_utc'],
      ),
      discardedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}discarded_at_utc'],
      ),
      printStatus: $MilkRecordsTable.$converterprintStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}print_status'],
        )!,
      ),
      lastPrintedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_printed_at_utc'],
      ),
      expiryRuleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expiry_rule_version'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $MilkRecordsTable createAlias(String alias) {
    return $MilkRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MilkStorageMode, String, String>
  $converterstorageMode = const EnumNameConverter<MilkStorageMode>(
    MilkStorageMode.values,
  );
  static JsonTypeConverter2<MilkStatus, String, String> $converterstatus =
      const EnumNameConverter<MilkStatus>(MilkStatus.values);
  static JsonTypeConverter2<PrintStatus, String, String> $converterprintStatus =
      const EnumNameConverter<PrintStatus>(PrintStatus.values);
}

class MilkRecordRow extends DataClass implements Insertable<MilkRecordRow> {
  final String id;
  final DateTime storedAtUtc;
  final int timezoneOffsetMinutes;
  final int amountMl;
  final MilkStorageMode storageMode;
  final String foodNotes;
  final MilkStatus status;
  final DateTime? bestUseAtUtc;
  final DateTime expiresAtUtc;
  final DateTime? thawStartedAtUtc;
  final DateTime? checkedOutAtUtc;
  final DateTime? discardedAtUtc;
  final PrintStatus printStatus;
  final DateTime? lastPrintedAtUtc;
  final String expiryRuleVersion;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  const MilkRecordRow({
    required this.id,
    required this.storedAtUtc,
    required this.timezoneOffsetMinutes,
    required this.amountMl,
    required this.storageMode,
    required this.foodNotes,
    required this.status,
    this.bestUseAtUtc,
    required this.expiresAtUtc,
    this.thawStartedAtUtc,
    this.checkedOutAtUtc,
    this.discardedAtUtc,
    required this.printStatus,
    this.lastPrintedAtUtc,
    required this.expiryRuleVersion,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['stored_at_utc'] = Variable<DateTime>(storedAtUtc);
    map['timezone_offset_minutes'] = Variable<int>(timezoneOffsetMinutes);
    map['amount_ml'] = Variable<int>(amountMl);
    {
      map['storage_mode'] = Variable<String>(
        $MilkRecordsTable.$converterstorageMode.toSql(storageMode),
      );
    }
    map['food_notes'] = Variable<String>(foodNotes);
    {
      map['status'] = Variable<String>(
        $MilkRecordsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || bestUseAtUtc != null) {
      map['best_use_at_utc'] = Variable<DateTime>(bestUseAtUtc);
    }
    map['expires_at_utc'] = Variable<DateTime>(expiresAtUtc);
    if (!nullToAbsent || thawStartedAtUtc != null) {
      map['thaw_started_at_utc'] = Variable<DateTime>(thawStartedAtUtc);
    }
    if (!nullToAbsent || checkedOutAtUtc != null) {
      map['checked_out_at_utc'] = Variable<DateTime>(checkedOutAtUtc);
    }
    if (!nullToAbsent || discardedAtUtc != null) {
      map['discarded_at_utc'] = Variable<DateTime>(discardedAtUtc);
    }
    {
      map['print_status'] = Variable<String>(
        $MilkRecordsTable.$converterprintStatus.toSql(printStatus),
      );
    }
    if (!nullToAbsent || lastPrintedAtUtc != null) {
      map['last_printed_at_utc'] = Variable<DateTime>(lastPrintedAtUtc);
    }
    map['expiry_rule_version'] = Variable<String>(expiryRuleVersion);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  MilkRecordsCompanion toCompanion(bool nullToAbsent) {
    return MilkRecordsCompanion(
      id: Value(id),
      storedAtUtc: Value(storedAtUtc),
      timezoneOffsetMinutes: Value(timezoneOffsetMinutes),
      amountMl: Value(amountMl),
      storageMode: Value(storageMode),
      foodNotes: Value(foodNotes),
      status: Value(status),
      bestUseAtUtc: bestUseAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(bestUseAtUtc),
      expiresAtUtc: Value(expiresAtUtc),
      thawStartedAtUtc: thawStartedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(thawStartedAtUtc),
      checkedOutAtUtc: checkedOutAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedOutAtUtc),
      discardedAtUtc: discardedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(discardedAtUtc),
      printStatus: Value(printStatus),
      lastPrintedAtUtc: lastPrintedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPrintedAtUtc),
      expiryRuleVersion: Value(expiryRuleVersion),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory MilkRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MilkRecordRow(
      id: serializer.fromJson<String>(json['id']),
      storedAtUtc: serializer.fromJson<DateTime>(json['storedAtUtc']),
      timezoneOffsetMinutes: serializer.fromJson<int>(
        json['timezoneOffsetMinutes'],
      ),
      amountMl: serializer.fromJson<int>(json['amountMl']),
      storageMode: $MilkRecordsTable.$converterstorageMode.fromJson(
        serializer.fromJson<String>(json['storageMode']),
      ),
      foodNotes: serializer.fromJson<String>(json['foodNotes']),
      status: $MilkRecordsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      bestUseAtUtc: serializer.fromJson<DateTime?>(json['bestUseAtUtc']),
      expiresAtUtc: serializer.fromJson<DateTime>(json['expiresAtUtc']),
      thawStartedAtUtc: serializer.fromJson<DateTime?>(
        json['thawStartedAtUtc'],
      ),
      checkedOutAtUtc: serializer.fromJson<DateTime?>(json['checkedOutAtUtc']),
      discardedAtUtc: serializer.fromJson<DateTime?>(json['discardedAtUtc']),
      printStatus: $MilkRecordsTable.$converterprintStatus.fromJson(
        serializer.fromJson<String>(json['printStatus']),
      ),
      lastPrintedAtUtc: serializer.fromJson<DateTime?>(
        json['lastPrintedAtUtc'],
      ),
      expiryRuleVersion: serializer.fromJson<String>(json['expiryRuleVersion']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storedAtUtc': serializer.toJson<DateTime>(storedAtUtc),
      'timezoneOffsetMinutes': serializer.toJson<int>(timezoneOffsetMinutes),
      'amountMl': serializer.toJson<int>(amountMl),
      'storageMode': serializer.toJson<String>(
        $MilkRecordsTable.$converterstorageMode.toJson(storageMode),
      ),
      'foodNotes': serializer.toJson<String>(foodNotes),
      'status': serializer.toJson<String>(
        $MilkRecordsTable.$converterstatus.toJson(status),
      ),
      'bestUseAtUtc': serializer.toJson<DateTime?>(bestUseAtUtc),
      'expiresAtUtc': serializer.toJson<DateTime>(expiresAtUtc),
      'thawStartedAtUtc': serializer.toJson<DateTime?>(thawStartedAtUtc),
      'checkedOutAtUtc': serializer.toJson<DateTime?>(checkedOutAtUtc),
      'discardedAtUtc': serializer.toJson<DateTime?>(discardedAtUtc),
      'printStatus': serializer.toJson<String>(
        $MilkRecordsTable.$converterprintStatus.toJson(printStatus),
      ),
      'lastPrintedAtUtc': serializer.toJson<DateTime?>(lastPrintedAtUtc),
      'expiryRuleVersion': serializer.toJson<String>(expiryRuleVersion),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  MilkRecordRow copyWith({
    String? id,
    DateTime? storedAtUtc,
    int? timezoneOffsetMinutes,
    int? amountMl,
    MilkStorageMode? storageMode,
    String? foodNotes,
    MilkStatus? status,
    Value<DateTime?> bestUseAtUtc = const Value.absent(),
    DateTime? expiresAtUtc,
    Value<DateTime?> thawStartedAtUtc = const Value.absent(),
    Value<DateTime?> checkedOutAtUtc = const Value.absent(),
    Value<DateTime?> discardedAtUtc = const Value.absent(),
    PrintStatus? printStatus,
    Value<DateTime?> lastPrintedAtUtc = const Value.absent(),
    String? expiryRuleVersion,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) => MilkRecordRow(
    id: id ?? this.id,
    storedAtUtc: storedAtUtc ?? this.storedAtUtc,
    timezoneOffsetMinutes: timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
    amountMl: amountMl ?? this.amountMl,
    storageMode: storageMode ?? this.storageMode,
    foodNotes: foodNotes ?? this.foodNotes,
    status: status ?? this.status,
    bestUseAtUtc: bestUseAtUtc.present ? bestUseAtUtc.value : this.bestUseAtUtc,
    expiresAtUtc: expiresAtUtc ?? this.expiresAtUtc,
    thawStartedAtUtc: thawStartedAtUtc.present
        ? thawStartedAtUtc.value
        : this.thawStartedAtUtc,
    checkedOutAtUtc: checkedOutAtUtc.present
        ? checkedOutAtUtc.value
        : this.checkedOutAtUtc,
    discardedAtUtc: discardedAtUtc.present
        ? discardedAtUtc.value
        : this.discardedAtUtc,
    printStatus: printStatus ?? this.printStatus,
    lastPrintedAtUtc: lastPrintedAtUtc.present
        ? lastPrintedAtUtc.value
        : this.lastPrintedAtUtc,
    expiryRuleVersion: expiryRuleVersion ?? this.expiryRuleVersion,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  MilkRecordRow copyWithCompanion(MilkRecordsCompanion data) {
    return MilkRecordRow(
      id: data.id.present ? data.id.value : this.id,
      storedAtUtc: data.storedAtUtc.present
          ? data.storedAtUtc.value
          : this.storedAtUtc,
      timezoneOffsetMinutes: data.timezoneOffsetMinutes.present
          ? data.timezoneOffsetMinutes.value
          : this.timezoneOffsetMinutes,
      amountMl: data.amountMl.present ? data.amountMl.value : this.amountMl,
      storageMode: data.storageMode.present
          ? data.storageMode.value
          : this.storageMode,
      foodNotes: data.foodNotes.present ? data.foodNotes.value : this.foodNotes,
      status: data.status.present ? data.status.value : this.status,
      bestUseAtUtc: data.bestUseAtUtc.present
          ? data.bestUseAtUtc.value
          : this.bestUseAtUtc,
      expiresAtUtc: data.expiresAtUtc.present
          ? data.expiresAtUtc.value
          : this.expiresAtUtc,
      thawStartedAtUtc: data.thawStartedAtUtc.present
          ? data.thawStartedAtUtc.value
          : this.thawStartedAtUtc,
      checkedOutAtUtc: data.checkedOutAtUtc.present
          ? data.checkedOutAtUtc.value
          : this.checkedOutAtUtc,
      discardedAtUtc: data.discardedAtUtc.present
          ? data.discardedAtUtc.value
          : this.discardedAtUtc,
      printStatus: data.printStatus.present
          ? data.printStatus.value
          : this.printStatus,
      lastPrintedAtUtc: data.lastPrintedAtUtc.present
          ? data.lastPrintedAtUtc.value
          : this.lastPrintedAtUtc,
      expiryRuleVersion: data.expiryRuleVersion.present
          ? data.expiryRuleVersion.value
          : this.expiryRuleVersion,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MilkRecordRow(')
          ..write('id: $id, ')
          ..write('storedAtUtc: $storedAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('amountMl: $amountMl, ')
          ..write('storageMode: $storageMode, ')
          ..write('foodNotes: $foodNotes, ')
          ..write('status: $status, ')
          ..write('bestUseAtUtc: $bestUseAtUtc, ')
          ..write('expiresAtUtc: $expiresAtUtc, ')
          ..write('thawStartedAtUtc: $thawStartedAtUtc, ')
          ..write('checkedOutAtUtc: $checkedOutAtUtc, ')
          ..write('discardedAtUtc: $discardedAtUtc, ')
          ..write('printStatus: $printStatus, ')
          ..write('lastPrintedAtUtc: $lastPrintedAtUtc, ')
          ..write('expiryRuleVersion: $expiryRuleVersion, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storedAtUtc,
    timezoneOffsetMinutes,
    amountMl,
    storageMode,
    foodNotes,
    status,
    bestUseAtUtc,
    expiresAtUtc,
    thawStartedAtUtc,
    checkedOutAtUtc,
    discardedAtUtc,
    printStatus,
    lastPrintedAtUtc,
    expiryRuleVersion,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MilkRecordRow &&
          other.id == this.id &&
          other.storedAtUtc == this.storedAtUtc &&
          other.timezoneOffsetMinutes == this.timezoneOffsetMinutes &&
          other.amountMl == this.amountMl &&
          other.storageMode == this.storageMode &&
          other.foodNotes == this.foodNotes &&
          other.status == this.status &&
          other.bestUseAtUtc == this.bestUseAtUtc &&
          other.expiresAtUtc == this.expiresAtUtc &&
          other.thawStartedAtUtc == this.thawStartedAtUtc &&
          other.checkedOutAtUtc == this.checkedOutAtUtc &&
          other.discardedAtUtc == this.discardedAtUtc &&
          other.printStatus == this.printStatus &&
          other.lastPrintedAtUtc == this.lastPrintedAtUtc &&
          other.expiryRuleVersion == this.expiryRuleVersion &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class MilkRecordsCompanion extends UpdateCompanion<MilkRecordRow> {
  final Value<String> id;
  final Value<DateTime> storedAtUtc;
  final Value<int> timezoneOffsetMinutes;
  final Value<int> amountMl;
  final Value<MilkStorageMode> storageMode;
  final Value<String> foodNotes;
  final Value<MilkStatus> status;
  final Value<DateTime?> bestUseAtUtc;
  final Value<DateTime> expiresAtUtc;
  final Value<DateTime?> thawStartedAtUtc;
  final Value<DateTime?> checkedOutAtUtc;
  final Value<DateTime?> discardedAtUtc;
  final Value<PrintStatus> printStatus;
  final Value<DateTime?> lastPrintedAtUtc;
  final Value<String> expiryRuleVersion;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const MilkRecordsCompanion({
    this.id = const Value.absent(),
    this.storedAtUtc = const Value.absent(),
    this.timezoneOffsetMinutes = const Value.absent(),
    this.amountMl = const Value.absent(),
    this.storageMode = const Value.absent(),
    this.foodNotes = const Value.absent(),
    this.status = const Value.absent(),
    this.bestUseAtUtc = const Value.absent(),
    this.expiresAtUtc = const Value.absent(),
    this.thawStartedAtUtc = const Value.absent(),
    this.checkedOutAtUtc = const Value.absent(),
    this.discardedAtUtc = const Value.absent(),
    this.printStatus = const Value.absent(),
    this.lastPrintedAtUtc = const Value.absent(),
    this.expiryRuleVersion = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MilkRecordsCompanion.insert({
    required String id,
    required DateTime storedAtUtc,
    required int timezoneOffsetMinutes,
    required int amountMl,
    required MilkStorageMode storageMode,
    this.foodNotes = const Value.absent(),
    required MilkStatus status,
    this.bestUseAtUtc = const Value.absent(),
    required DateTime expiresAtUtc,
    this.thawStartedAtUtc = const Value.absent(),
    this.checkedOutAtUtc = const Value.absent(),
    this.discardedAtUtc = const Value.absent(),
    required PrintStatus printStatus,
    this.lastPrintedAtUtc = const Value.absent(),
    required String expiryRuleVersion,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storedAtUtc = Value(storedAtUtc),
       timezoneOffsetMinutes = Value(timezoneOffsetMinutes),
       amountMl = Value(amountMl),
       storageMode = Value(storageMode),
       status = Value(status),
       expiresAtUtc = Value(expiresAtUtc),
       printStatus = Value(printStatus),
       expiryRuleVersion = Value(expiryRuleVersion),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<MilkRecordRow> custom({
    Expression<String>? id,
    Expression<DateTime>? storedAtUtc,
    Expression<int>? timezoneOffsetMinutes,
    Expression<int>? amountMl,
    Expression<String>? storageMode,
    Expression<String>? foodNotes,
    Expression<String>? status,
    Expression<DateTime>? bestUseAtUtc,
    Expression<DateTime>? expiresAtUtc,
    Expression<DateTime>? thawStartedAtUtc,
    Expression<DateTime>? checkedOutAtUtc,
    Expression<DateTime>? discardedAtUtc,
    Expression<String>? printStatus,
    Expression<DateTime>? lastPrintedAtUtc,
    Expression<String>? expiryRuleVersion,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storedAtUtc != null) 'stored_at_utc': storedAtUtc,
      if (timezoneOffsetMinutes != null)
        'timezone_offset_minutes': timezoneOffsetMinutes,
      if (amountMl != null) 'amount_ml': amountMl,
      if (storageMode != null) 'storage_mode': storageMode,
      if (foodNotes != null) 'food_notes': foodNotes,
      if (status != null) 'status': status,
      if (bestUseAtUtc != null) 'best_use_at_utc': bestUseAtUtc,
      if (expiresAtUtc != null) 'expires_at_utc': expiresAtUtc,
      if (thawStartedAtUtc != null) 'thaw_started_at_utc': thawStartedAtUtc,
      if (checkedOutAtUtc != null) 'checked_out_at_utc': checkedOutAtUtc,
      if (discardedAtUtc != null) 'discarded_at_utc': discardedAtUtc,
      if (printStatus != null) 'print_status': printStatus,
      if (lastPrintedAtUtc != null) 'last_printed_at_utc': lastPrintedAtUtc,
      if (expiryRuleVersion != null) 'expiry_rule_version': expiryRuleVersion,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MilkRecordsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? storedAtUtc,
    Value<int>? timezoneOffsetMinutes,
    Value<int>? amountMl,
    Value<MilkStorageMode>? storageMode,
    Value<String>? foodNotes,
    Value<MilkStatus>? status,
    Value<DateTime?>? bestUseAtUtc,
    Value<DateTime>? expiresAtUtc,
    Value<DateTime?>? thawStartedAtUtc,
    Value<DateTime?>? checkedOutAtUtc,
    Value<DateTime?>? discardedAtUtc,
    Value<PrintStatus>? printStatus,
    Value<DateTime?>? lastPrintedAtUtc,
    Value<String>? expiryRuleVersion,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return MilkRecordsCompanion(
      id: id ?? this.id,
      storedAtUtc: storedAtUtc ?? this.storedAtUtc,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      amountMl: amountMl ?? this.amountMl,
      storageMode: storageMode ?? this.storageMode,
      foodNotes: foodNotes ?? this.foodNotes,
      status: status ?? this.status,
      bestUseAtUtc: bestUseAtUtc ?? this.bestUseAtUtc,
      expiresAtUtc: expiresAtUtc ?? this.expiresAtUtc,
      thawStartedAtUtc: thawStartedAtUtc ?? this.thawStartedAtUtc,
      checkedOutAtUtc: checkedOutAtUtc ?? this.checkedOutAtUtc,
      discardedAtUtc: discardedAtUtc ?? this.discardedAtUtc,
      printStatus: printStatus ?? this.printStatus,
      lastPrintedAtUtc: lastPrintedAtUtc ?? this.lastPrintedAtUtc,
      expiryRuleVersion: expiryRuleVersion ?? this.expiryRuleVersion,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storedAtUtc.present) {
      map['stored_at_utc'] = Variable<DateTime>(storedAtUtc.value);
    }
    if (timezoneOffsetMinutes.present) {
      map['timezone_offset_minutes'] = Variable<int>(
        timezoneOffsetMinutes.value,
      );
    }
    if (amountMl.present) {
      map['amount_ml'] = Variable<int>(amountMl.value);
    }
    if (storageMode.present) {
      map['storage_mode'] = Variable<String>(
        $MilkRecordsTable.$converterstorageMode.toSql(storageMode.value),
      );
    }
    if (foodNotes.present) {
      map['food_notes'] = Variable<String>(foodNotes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $MilkRecordsTable.$converterstatus.toSql(status.value),
      );
    }
    if (bestUseAtUtc.present) {
      map['best_use_at_utc'] = Variable<DateTime>(bestUseAtUtc.value);
    }
    if (expiresAtUtc.present) {
      map['expires_at_utc'] = Variable<DateTime>(expiresAtUtc.value);
    }
    if (thawStartedAtUtc.present) {
      map['thaw_started_at_utc'] = Variable<DateTime>(thawStartedAtUtc.value);
    }
    if (checkedOutAtUtc.present) {
      map['checked_out_at_utc'] = Variable<DateTime>(checkedOutAtUtc.value);
    }
    if (discardedAtUtc.present) {
      map['discarded_at_utc'] = Variable<DateTime>(discardedAtUtc.value);
    }
    if (printStatus.present) {
      map['print_status'] = Variable<String>(
        $MilkRecordsTable.$converterprintStatus.toSql(printStatus.value),
      );
    }
    if (lastPrintedAtUtc.present) {
      map['last_printed_at_utc'] = Variable<DateTime>(lastPrintedAtUtc.value);
    }
    if (expiryRuleVersion.present) {
      map['expiry_rule_version'] = Variable<String>(expiryRuleVersion.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilkRecordsCompanion(')
          ..write('id: $id, ')
          ..write('storedAtUtc: $storedAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('amountMl: $amountMl, ')
          ..write('storageMode: $storageMode, ')
          ..write('foodNotes: $foodNotes, ')
          ..write('status: $status, ')
          ..write('bestUseAtUtc: $bestUseAtUtc, ')
          ..write('expiresAtUtc: $expiresAtUtc, ')
          ..write('thawStartedAtUtc: $thawStartedAtUtc, ')
          ..write('checkedOutAtUtc: $checkedOutAtUtc, ')
          ..write('discardedAtUtc: $discardedAtUtc, ')
          ..write('printStatus: $printStatus, ')
          ..write('lastPrintedAtUtc: $lastPrintedAtUtc, ')
          ..write('expiryRuleVersion: $expiryRuleVersion, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MilkStatusEventsTable extends MilkStatusEvents
    with TableInfo<$MilkStatusEventsTable, MilkStatusEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilkStatusEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _milkIdMeta = const VerificationMeta('milkId');
  @override
  late final GeneratedColumn<String> milkId = GeneratedColumn<String>(
    'milk_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES milk_records (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MilkStatusEventType, String>
  type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MilkStatusEventType>($MilkStatusEventsTable.$convertertype);
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MilkStatus?, String> fromStatus =
      GeneratedColumn<String>(
        'from_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<MilkStatus?>(
        $MilkStatusEventsTable.$converterfromStatusn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MilkStatus, String> toStatus =
      GeneratedColumn<String>(
        'to_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MilkStatus>($MilkStatusEventsTable.$convertertoStatus);
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    milkId,
    type,
    occurredAtUtc,
    fromStatus,
    toStatus,
    metadataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milk_status_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<MilkStatusEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('milk_id')) {
      context.handle(
        _milkIdMeta,
        milkId.isAcceptableOrUnknown(data['milk_id']!, _milkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_milkIdMeta);
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MilkStatusEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MilkStatusEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      milkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}milk_id'],
      )!,
      type: $MilkStatusEventsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
      fromStatus: $MilkStatusEventsTable.$converterfromStatusn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}from_status'],
        ),
      ),
      toStatus: $MilkStatusEventsTable.$convertertoStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}to_status'],
        )!,
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
    );
  }

  @override
  $MilkStatusEventsTable createAlias(String alias) {
    return $MilkStatusEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MilkStatusEventType, String, String>
  $convertertype = const EnumNameConverter<MilkStatusEventType>(
    MilkStatusEventType.values,
  );
  static JsonTypeConverter2<MilkStatus, String, String> $converterfromStatus =
      const EnumNameConverter<MilkStatus>(MilkStatus.values);
  static JsonTypeConverter2<MilkStatus?, String?, String?>
  $converterfromStatusn = JsonTypeConverter2.asNullable($converterfromStatus);
  static JsonTypeConverter2<MilkStatus, String, String> $convertertoStatus =
      const EnumNameConverter<MilkStatus>(MilkStatus.values);
}

class MilkStatusEventRow extends DataClass
    implements Insertable<MilkStatusEventRow> {
  final String id;
  final String milkId;
  final MilkStatusEventType type;
  final DateTime occurredAtUtc;
  final MilkStatus? fromStatus;
  final MilkStatus toStatus;
  final String metadataJson;
  const MilkStatusEventRow({
    required this.id,
    required this.milkId,
    required this.type,
    required this.occurredAtUtc,
    this.fromStatus,
    required this.toStatus,
    required this.metadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['milk_id'] = Variable<String>(milkId);
    {
      map['type'] = Variable<String>(
        $MilkStatusEventsTable.$convertertype.toSql(type),
      );
    }
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    if (!nullToAbsent || fromStatus != null) {
      map['from_status'] = Variable<String>(
        $MilkStatusEventsTable.$converterfromStatusn.toSql(fromStatus),
      );
    }
    {
      map['to_status'] = Variable<String>(
        $MilkStatusEventsTable.$convertertoStatus.toSql(toStatus),
      );
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    return map;
  }

  MilkStatusEventsCompanion toCompanion(bool nullToAbsent) {
    return MilkStatusEventsCompanion(
      id: Value(id),
      milkId: Value(milkId),
      type: Value(type),
      occurredAtUtc: Value(occurredAtUtc),
      fromStatus: fromStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(fromStatus),
      toStatus: Value(toStatus),
      metadataJson: Value(metadataJson),
    );
  }

  factory MilkStatusEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MilkStatusEventRow(
      id: serializer.fromJson<String>(json['id']),
      milkId: serializer.fromJson<String>(json['milkId']),
      type: $MilkStatusEventsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
      fromStatus: $MilkStatusEventsTable.$converterfromStatusn.fromJson(
        serializer.fromJson<String?>(json['fromStatus']),
      ),
      toStatus: $MilkStatusEventsTable.$convertertoStatus.fromJson(
        serializer.fromJson<String>(json['toStatus']),
      ),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'milkId': serializer.toJson<String>(milkId),
      'type': serializer.toJson<String>(
        $MilkStatusEventsTable.$convertertype.toJson(type),
      ),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
      'fromStatus': serializer.toJson<String?>(
        $MilkStatusEventsTable.$converterfromStatusn.toJson(fromStatus),
      ),
      'toStatus': serializer.toJson<String>(
        $MilkStatusEventsTable.$convertertoStatus.toJson(toStatus),
      ),
      'metadataJson': serializer.toJson<String>(metadataJson),
    };
  }

  MilkStatusEventRow copyWith({
    String? id,
    String? milkId,
    MilkStatusEventType? type,
    DateTime? occurredAtUtc,
    Value<MilkStatus?> fromStatus = const Value.absent(),
    MilkStatus? toStatus,
    String? metadataJson,
  }) => MilkStatusEventRow(
    id: id ?? this.id,
    milkId: milkId ?? this.milkId,
    type: type ?? this.type,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
    fromStatus: fromStatus.present ? fromStatus.value : this.fromStatus,
    toStatus: toStatus ?? this.toStatus,
    metadataJson: metadataJson ?? this.metadataJson,
  );
  MilkStatusEventRow copyWithCompanion(MilkStatusEventsCompanion data) {
    return MilkStatusEventRow(
      id: data.id.present ? data.id.value : this.id,
      milkId: data.milkId.present ? data.milkId.value : this.milkId,
      type: data.type.present ? data.type.value : this.type,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      fromStatus: data.fromStatus.present
          ? data.fromStatus.value
          : this.fromStatus,
      toStatus: data.toStatus.present ? data.toStatus.value : this.toStatus,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MilkStatusEventRow(')
          ..write('id: $id, ')
          ..write('milkId: $milkId, ')
          ..write('type: $type, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    milkId,
    type,
    occurredAtUtc,
    fromStatus,
    toStatus,
    metadataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MilkStatusEventRow &&
          other.id == this.id &&
          other.milkId == this.milkId &&
          other.type == this.type &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.fromStatus == this.fromStatus &&
          other.toStatus == this.toStatus &&
          other.metadataJson == this.metadataJson);
}

class MilkStatusEventsCompanion extends UpdateCompanion<MilkStatusEventRow> {
  final Value<String> id;
  final Value<String> milkId;
  final Value<MilkStatusEventType> type;
  final Value<DateTime> occurredAtUtc;
  final Value<MilkStatus?> fromStatus;
  final Value<MilkStatus> toStatus;
  final Value<String> metadataJson;
  final Value<int> rowid;
  const MilkStatusEventsCompanion({
    this.id = const Value.absent(),
    this.milkId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.fromStatus = const Value.absent(),
    this.toStatus = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MilkStatusEventsCompanion.insert({
    required String id,
    required String milkId,
    required MilkStatusEventType type,
    required DateTime occurredAtUtc,
    this.fromStatus = const Value.absent(),
    required MilkStatus toStatus,
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       milkId = Value(milkId),
       type = Value(type),
       occurredAtUtc = Value(occurredAtUtc),
       toStatus = Value(toStatus);
  static Insertable<MilkStatusEventRow> custom({
    Expression<String>? id,
    Expression<String>? milkId,
    Expression<String>? type,
    Expression<DateTime>? occurredAtUtc,
    Expression<String>? fromStatus,
    Expression<String>? toStatus,
    Expression<String>? metadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (milkId != null) 'milk_id': milkId,
      if (type != null) 'type': type,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (fromStatus != null) 'from_status': fromStatus,
      if (toStatus != null) 'to_status': toStatus,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MilkStatusEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? milkId,
    Value<MilkStatusEventType>? type,
    Value<DateTime>? occurredAtUtc,
    Value<MilkStatus?>? fromStatus,
    Value<MilkStatus>? toStatus,
    Value<String>? metadataJson,
    Value<int>? rowid,
  }) {
    return MilkStatusEventsCompanion(
      id: id ?? this.id,
      milkId: milkId ?? this.milkId,
      type: type ?? this.type,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      fromStatus: fromStatus ?? this.fromStatus,
      toStatus: toStatus ?? this.toStatus,
      metadataJson: metadataJson ?? this.metadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (milkId.present) {
      map['milk_id'] = Variable<String>(milkId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $MilkStatusEventsTable.$convertertype.toSql(type.value),
      );
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (fromStatus.present) {
      map['from_status'] = Variable<String>(
        $MilkStatusEventsTable.$converterfromStatusn.toSql(fromStatus.value),
      );
    }
    if (toStatus.present) {
      map['to_status'] = Variable<String>(
        $MilkStatusEventsTable.$convertertoStatus.toSql(toStatus.value),
      );
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilkStatusEventsCompanion(')
          ..write('id: $id, ')
          ..write('milkId: $milkId, ')
          ..write('type: $type, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodTagsTable extends FoodTags
    with TableInfo<$FoodTagsTable, FoodTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtUtcMeta = const VerificationMeta(
    'lastUsedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAtUtc =
      GeneratedColumn<DateTime>(
        'last_used_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _useCountMeta = const VerificationMeta(
    'useCount',
  );
  @override
  late final GeneratedColumn<int> useCount = GeneratedColumn<int>(
    'use_count',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('use_count >= 0'),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAtUtc,
    updatedAtUtc,
    lastUsedAtUtc,
    useCount,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('last_used_at_utc')) {
      context.handle(
        _lastUsedAtUtcMeta,
        lastUsedAtUtc.isAcceptableOrUnknown(
          data['last_used_at_utc']!,
          _lastUsedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('use_count')) {
      context.handle(
        _useCountMeta,
        useCount.isAcceptableOrUnknown(data['use_count']!, _useCountMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodTagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      lastUsedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at_utc'],
      ),
      useCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}use_count'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $FoodTagsTable createAlias(String alias) {
    return $FoodTagsTable(attachedDatabase, alias);
  }
}

class FoodTagRow extends DataClass implements Insertable<FoodTagRow> {
  final String id;
  final String name;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? lastUsedAtUtc;
  final int useCount;

  /// Soft-delete: hidden from common lists, kept for historical record links.
  final bool isActive;
  const FoodTagRow({
    required this.id,
    required this.name,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.lastUsedAtUtc,
    required this.useCount,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    if (!nullToAbsent || lastUsedAtUtc != null) {
      map['last_used_at_utc'] = Variable<DateTime>(lastUsedAtUtc);
    }
    map['use_count'] = Variable<int>(useCount);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  FoodTagsCompanion toCompanion(bool nullToAbsent) {
    return FoodTagsCompanion(
      id: Value(id),
      name: Value(name),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      lastUsedAtUtc: lastUsedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAtUtc),
      useCount: Value(useCount),
      isActive: Value(isActive),
    );
  }

  factory FoodTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodTagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      lastUsedAtUtc: serializer.fromJson<DateTime?>(json['lastUsedAtUtc']),
      useCount: serializer.fromJson<int>(json['useCount']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'lastUsedAtUtc': serializer.toJson<DateTime?>(lastUsedAtUtc),
      'useCount': serializer.toJson<int>(useCount),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  FoodTagRow copyWith({
    String? id,
    String? name,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<DateTime?> lastUsedAtUtc = const Value.absent(),
    int? useCount,
    bool? isActive,
  }) => FoodTagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    lastUsedAtUtc: lastUsedAtUtc.present
        ? lastUsedAtUtc.value
        : this.lastUsedAtUtc,
    useCount: useCount ?? this.useCount,
    isActive: isActive ?? this.isActive,
  );
  FoodTagRow copyWithCompanion(FoodTagsCompanion data) {
    return FoodTagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      lastUsedAtUtc: data.lastUsedAtUtc.present
          ? data.lastUsedAtUtc.value
          : this.lastUsedAtUtc,
      useCount: data.useCount.present ? data.useCount.value : this.useCount,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodTagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('lastUsedAtUtc: $lastUsedAtUtc, ')
          ..write('useCount: $useCount, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    createdAtUtc,
    updatedAtUtc,
    lastUsedAtUtc,
    useCount,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodTagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.lastUsedAtUtc == this.lastUsedAtUtc &&
          other.useCount == this.useCount &&
          other.isActive == this.isActive);
}

class FoodTagsCompanion extends UpdateCompanion<FoodTagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<DateTime?> lastUsedAtUtc;
  final Value<int> useCount;
  final Value<bool> isActive;
  final Value<int> rowid;
  const FoodTagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.lastUsedAtUtc = const Value.absent(),
    this.useCount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodTagsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.lastUsedAtUtc = const Value.absent(),
    this.useCount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<FoodTagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<DateTime>? lastUsedAtUtc,
    Expression<int>? useCount,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (lastUsedAtUtc != null) 'last_used_at_utc': lastUsedAtUtc,
      if (useCount != null) 'use_count': useCount,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodTagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<DateTime?>? lastUsedAtUtc,
    Value<int>? useCount,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return FoodTagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      lastUsedAtUtc: lastUsedAtUtc ?? this.lastUsedAtUtc,
      useCount: useCount ?? this.useCount,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (lastUsedAtUtc.present) {
      map['last_used_at_utc'] = Variable<DateTime>(lastUsedAtUtc.value);
    }
    if (useCount.present) {
      map['use_count'] = Variable<int>(useCount.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodTagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('lastUsedAtUtc: $lastUsedAtUtc, ')
          ..write('useCount: $useCount, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MilkFoodTagsTable extends MilkFoodTags
    with TableInfo<$MilkFoodTagsTable, MilkFoodTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilkFoodTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _milkIdMeta = const VerificationMeta('milkId');
  @override
  late final GeneratedColumn<String> milkId = GeneratedColumn<String>(
    'milk_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES milk_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _foodTagIdMeta = const VerificationMeta(
    'foodTagId',
  );
  @override
  late final GeneratedColumn<String> foodTagId = GeneratedColumn<String>(
    'food_tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES food_tags (id) ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [milkId, foodTagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milk_food_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<MilkFoodTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('milk_id')) {
      context.handle(
        _milkIdMeta,
        milkId.isAcceptableOrUnknown(data['milk_id']!, _milkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_milkIdMeta);
    }
    if (data.containsKey('food_tag_id')) {
      context.handle(
        _foodTagIdMeta,
        foodTagId.isAcceptableOrUnknown(data['food_tag_id']!, _foodTagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodTagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {milkId, foodTagId};
  @override
  MilkFoodTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MilkFoodTagRow(
      milkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}milk_id'],
      )!,
      foodTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_tag_id'],
      )!,
    );
  }

  @override
  $MilkFoodTagsTable createAlias(String alias) {
    return $MilkFoodTagsTable(attachedDatabase, alias);
  }
}

class MilkFoodTagRow extends DataClass implements Insertable<MilkFoodTagRow> {
  final String milkId;
  final String foodTagId;
  const MilkFoodTagRow({required this.milkId, required this.foodTagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['milk_id'] = Variable<String>(milkId);
    map['food_tag_id'] = Variable<String>(foodTagId);
    return map;
  }

  MilkFoodTagsCompanion toCompanion(bool nullToAbsent) {
    return MilkFoodTagsCompanion(
      milkId: Value(milkId),
      foodTagId: Value(foodTagId),
    );
  }

  factory MilkFoodTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MilkFoodTagRow(
      milkId: serializer.fromJson<String>(json['milkId']),
      foodTagId: serializer.fromJson<String>(json['foodTagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'milkId': serializer.toJson<String>(milkId),
      'foodTagId': serializer.toJson<String>(foodTagId),
    };
  }

  MilkFoodTagRow copyWith({String? milkId, String? foodTagId}) =>
      MilkFoodTagRow(
        milkId: milkId ?? this.milkId,
        foodTagId: foodTagId ?? this.foodTagId,
      );
  MilkFoodTagRow copyWithCompanion(MilkFoodTagsCompanion data) {
    return MilkFoodTagRow(
      milkId: data.milkId.present ? data.milkId.value : this.milkId,
      foodTagId: data.foodTagId.present ? data.foodTagId.value : this.foodTagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MilkFoodTagRow(')
          ..write('milkId: $milkId, ')
          ..write('foodTagId: $foodTagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(milkId, foodTagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MilkFoodTagRow &&
          other.milkId == this.milkId &&
          other.foodTagId == this.foodTagId);
}

class MilkFoodTagsCompanion extends UpdateCompanion<MilkFoodTagRow> {
  final Value<String> milkId;
  final Value<String> foodTagId;
  final Value<int> rowid;
  const MilkFoodTagsCompanion({
    this.milkId = const Value.absent(),
    this.foodTagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MilkFoodTagsCompanion.insert({
    required String milkId,
    required String foodTagId,
    this.rowid = const Value.absent(),
  }) : milkId = Value(milkId),
       foodTagId = Value(foodTagId);
  static Insertable<MilkFoodTagRow> custom({
    Expression<String>? milkId,
    Expression<String>? foodTagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (milkId != null) 'milk_id': milkId,
      if (foodTagId != null) 'food_tag_id': foodTagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MilkFoodTagsCompanion copyWith({
    Value<String>? milkId,
    Value<String>? foodTagId,
    Value<int>? rowid,
  }) {
    return MilkFoodTagsCompanion(
      milkId: milkId ?? this.milkId,
      foodTagId: foodTagId ?? this.foodTagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (milkId.present) {
      map['milk_id'] = Variable<String>(milkId.value);
    }
    if (foodTagId.present) {
      map['food_tag_id'] = Variable<String>(foodTagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilkFoodTagsCompanion(')
          ..write('milkId: $milkId, ')
          ..write('foodTagId: $foodTagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueJson, updatedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String valueJson;
  final DateTime updatedAtUtc;
  const AppSettingRow({
    required this.key,
    required this.valueJson,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      valueJson: Value(valueJson),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  AppSettingRow copyWith({
    String? key,
    String? valueJson,
    DateTime? updatedAtUtc,
  }) => AppSettingRow(
    key: key ?? this.key,
    valueJson: valueJson ?? this.valueJson,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson, updatedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String valueJson,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MilkRecordsTable milkRecords = $MilkRecordsTable(this);
  late final $MilkStatusEventsTable milkStatusEvents = $MilkStatusEventsTable(
    this,
  );
  late final $FoodTagsTable foodTags = $FoodTagsTable(this);
  late final $MilkFoodTagsTable milkFoodTags = $MilkFoodTagsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    milkRecords,
    milkStatusEvents,
    foodTags,
    milkFoodTags,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'milk_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('milk_status_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'milk_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('milk_food_tags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MilkRecordsTableCreateCompanionBuilder =
    MilkRecordsCompanion Function({
      required String id,
      required DateTime storedAtUtc,
      required int timezoneOffsetMinutes,
      required int amountMl,
      required MilkStorageMode storageMode,
      Value<String> foodNotes,
      required MilkStatus status,
      Value<DateTime?> bestUseAtUtc,
      required DateTime expiresAtUtc,
      Value<DateTime?> thawStartedAtUtc,
      Value<DateTime?> checkedOutAtUtc,
      Value<DateTime?> discardedAtUtc,
      required PrintStatus printStatus,
      Value<DateTime?> lastPrintedAtUtc,
      required String expiryRuleVersion,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$MilkRecordsTableUpdateCompanionBuilder =
    MilkRecordsCompanion Function({
      Value<String> id,
      Value<DateTime> storedAtUtc,
      Value<int> timezoneOffsetMinutes,
      Value<int> amountMl,
      Value<MilkStorageMode> storageMode,
      Value<String> foodNotes,
      Value<MilkStatus> status,
      Value<DateTime?> bestUseAtUtc,
      Value<DateTime> expiresAtUtc,
      Value<DateTime?> thawStartedAtUtc,
      Value<DateTime?> checkedOutAtUtc,
      Value<DateTime?> discardedAtUtc,
      Value<PrintStatus> printStatus,
      Value<DateTime?> lastPrintedAtUtc,
      Value<String> expiryRuleVersion,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

final class $$MilkRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $MilkRecordsTable, MilkRecordRow> {
  $$MilkRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MilkStatusEventsTable, List<MilkStatusEventRow>>
  _milkStatusEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.milkStatusEvents,
    aliasName: 'milk_records__id__milk_status_events__milk_id',
  );

  $$MilkStatusEventsTableProcessedTableManager get milkStatusEventsRefs {
    final manager = $$MilkStatusEventsTableTableManager(
      $_db,
      $_db.milkStatusEvents,
    ).filter((f) => f.milkId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _milkStatusEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MilkFoodTagsTable, List<MilkFoodTagRow>>
  _milkFoodTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.milkFoodTags,
    aliasName: 'milk_records__id__milk_food_tags__milk_id',
  );

  $$MilkFoodTagsTableProcessedTableManager get milkFoodTagsRefs {
    final manager = $$MilkFoodTagsTableTableManager(
      $_db,
      $_db.milkFoodTags,
    ).filter((f) => f.milkId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_milkFoodTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MilkRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MilkRecordsTable> {
  $$MilkRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get storedAtUtc => $composableBuilder(
    column: $table.storedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMl => $composableBuilder(
    column: $table.amountMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MilkStorageMode, MilkStorageMode, String>
  get storageMode => $composableBuilder(
    column: $table.storageMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get foodNotes => $composableBuilder(
    column: $table.foodNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MilkStatus, MilkStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get bestUseAtUtc => $composableBuilder(
    column: $table.bestUseAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAtUtc => $composableBuilder(
    column: $table.expiresAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get thawStartedAtUtc => $composableBuilder(
    column: $table.thawStartedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkedOutAtUtc => $composableBuilder(
    column: $table.checkedOutAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get discardedAtUtc => $composableBuilder(
    column: $table.discardedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PrintStatus, PrintStatus, String>
  get printStatus => $composableBuilder(
    column: $table.printStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastPrintedAtUtc => $composableBuilder(
    column: $table.lastPrintedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expiryRuleVersion => $composableBuilder(
    column: $table.expiryRuleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> milkStatusEventsRefs(
    Expression<bool> Function($$MilkStatusEventsTableFilterComposer f) f,
  ) {
    final $$MilkStatusEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milkStatusEvents,
      getReferencedColumn: (t) => t.milkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkStatusEventsTableFilterComposer(
            $db: $db,
            $table: $db.milkStatusEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> milkFoodTagsRefs(
    Expression<bool> Function($$MilkFoodTagsTableFilterComposer f) f,
  ) {
    final $$MilkFoodTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milkFoodTags,
      getReferencedColumn: (t) => t.milkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkFoodTagsTableFilterComposer(
            $db: $db,
            $table: $db.milkFoodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MilkRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MilkRecordsTable> {
  $$MilkRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get storedAtUtc => $composableBuilder(
    column: $table.storedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMl => $composableBuilder(
    column: $table.amountMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageMode => $composableBuilder(
    column: $table.storageMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodNotes => $composableBuilder(
    column: $table.foodNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bestUseAtUtc => $composableBuilder(
    column: $table.bestUseAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAtUtc => $composableBuilder(
    column: $table.expiresAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get thawStartedAtUtc => $composableBuilder(
    column: $table.thawStartedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedOutAtUtc => $composableBuilder(
    column: $table.checkedOutAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get discardedAtUtc => $composableBuilder(
    column: $table.discardedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printStatus => $composableBuilder(
    column: $table.printStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPrintedAtUtc => $composableBuilder(
    column: $table.lastPrintedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiryRuleVersion => $composableBuilder(
    column: $table.expiryRuleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MilkRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MilkRecordsTable> {
  $$MilkRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get storedAtUtc => $composableBuilder(
    column: $table.storedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMl =>
      $composableBuilder(column: $table.amountMl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MilkStorageMode, String> get storageMode =>
      $composableBuilder(
        column: $table.storageMode,
        builder: (column) => column,
      );

  GeneratedColumn<String> get foodNotes =>
      $composableBuilder(column: $table.foodNotes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MilkStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get bestUseAtUtc => $composableBuilder(
    column: $table.bestUseAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAtUtc => $composableBuilder(
    column: $table.expiresAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get thawStartedAtUtc => $composableBuilder(
    column: $table.thawStartedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkedOutAtUtc => $composableBuilder(
    column: $table.checkedOutAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get discardedAtUtc => $composableBuilder(
    column: $table.discardedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PrintStatus, String> get printStatus =>
      $composableBuilder(
        column: $table.printStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastPrintedAtUtc => $composableBuilder(
    column: $table.lastPrintedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expiryRuleVersion => $composableBuilder(
    column: $table.expiryRuleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  Expression<T> milkStatusEventsRefs<T extends Object>(
    Expression<T> Function($$MilkStatusEventsTableAnnotationComposer a) f,
  ) {
    final $$MilkStatusEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milkStatusEvents,
      getReferencedColumn: (t) => t.milkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkStatusEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.milkStatusEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> milkFoodTagsRefs<T extends Object>(
    Expression<T> Function($$MilkFoodTagsTableAnnotationComposer a) f,
  ) {
    final $$MilkFoodTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milkFoodTags,
      getReferencedColumn: (t) => t.milkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkFoodTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.milkFoodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MilkRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilkRecordsTable,
          MilkRecordRow,
          $$MilkRecordsTableFilterComposer,
          $$MilkRecordsTableOrderingComposer,
          $$MilkRecordsTableAnnotationComposer,
          $$MilkRecordsTableCreateCompanionBuilder,
          $$MilkRecordsTableUpdateCompanionBuilder,
          (MilkRecordRow, $$MilkRecordsTableReferences),
          MilkRecordRow,
          PrefetchHooks Function({
            bool milkStatusEventsRefs,
            bool milkFoodTagsRefs,
          })
        > {
  $$MilkRecordsTableTableManager(_$AppDatabase db, $MilkRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MilkRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MilkRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MilkRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> storedAtUtc = const Value.absent(),
                Value<int> timezoneOffsetMinutes = const Value.absent(),
                Value<int> amountMl = const Value.absent(),
                Value<MilkStorageMode> storageMode = const Value.absent(),
                Value<String> foodNotes = const Value.absent(),
                Value<MilkStatus> status = const Value.absent(),
                Value<DateTime?> bestUseAtUtc = const Value.absent(),
                Value<DateTime> expiresAtUtc = const Value.absent(),
                Value<DateTime?> thawStartedAtUtc = const Value.absent(),
                Value<DateTime?> checkedOutAtUtc = const Value.absent(),
                Value<DateTime?> discardedAtUtc = const Value.absent(),
                Value<PrintStatus> printStatus = const Value.absent(),
                Value<DateTime?> lastPrintedAtUtc = const Value.absent(),
                Value<String> expiryRuleVersion = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilkRecordsCompanion(
                id: id,
                storedAtUtc: storedAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                amountMl: amountMl,
                storageMode: storageMode,
                foodNotes: foodNotes,
                status: status,
                bestUseAtUtc: bestUseAtUtc,
                expiresAtUtc: expiresAtUtc,
                thawStartedAtUtc: thawStartedAtUtc,
                checkedOutAtUtc: checkedOutAtUtc,
                discardedAtUtc: discardedAtUtc,
                printStatus: printStatus,
                lastPrintedAtUtc: lastPrintedAtUtc,
                expiryRuleVersion: expiryRuleVersion,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime storedAtUtc,
                required int timezoneOffsetMinutes,
                required int amountMl,
                required MilkStorageMode storageMode,
                Value<String> foodNotes = const Value.absent(),
                required MilkStatus status,
                Value<DateTime?> bestUseAtUtc = const Value.absent(),
                required DateTime expiresAtUtc,
                Value<DateTime?> thawStartedAtUtc = const Value.absent(),
                Value<DateTime?> checkedOutAtUtc = const Value.absent(),
                Value<DateTime?> discardedAtUtc = const Value.absent(),
                required PrintStatus printStatus,
                Value<DateTime?> lastPrintedAtUtc = const Value.absent(),
                required String expiryRuleVersion,
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => MilkRecordsCompanion.insert(
                id: id,
                storedAtUtc: storedAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                amountMl: amountMl,
                storageMode: storageMode,
                foodNotes: foodNotes,
                status: status,
                bestUseAtUtc: bestUseAtUtc,
                expiresAtUtc: expiresAtUtc,
                thawStartedAtUtc: thawStartedAtUtc,
                checkedOutAtUtc: checkedOutAtUtc,
                discardedAtUtc: discardedAtUtc,
                printStatus: printStatus,
                lastPrintedAtUtc: lastPrintedAtUtc,
                expiryRuleVersion: expiryRuleVersion,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MilkRecordsTable, MilkRecordRow>(table),
                  $$MilkRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({milkStatusEventsRefs = false, milkFoodTagsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (milkStatusEventsRefs) db.milkStatusEvents,
                    if (milkFoodTagsRefs) db.milkFoodTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (milkStatusEventsRefs)
                        await $_getPrefetchedData<
                          MilkRecordRow,
                          $MilkRecordsTable,
                          MilkStatusEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$MilkRecordsTableReferences
                              ._milkStatusEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MilkRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).milkStatusEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.milkId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (milkFoodTagsRefs)
                        await $_getPrefetchedData<
                          MilkRecordRow,
                          $MilkRecordsTable,
                          MilkFoodTagRow
                        >(
                          currentTable: table,
                          referencedTable: $$MilkRecordsTableReferences
                              ._milkFoodTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MilkRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).milkFoodTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.milkId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MilkRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilkRecordsTable,
      MilkRecordRow,
      $$MilkRecordsTableFilterComposer,
      $$MilkRecordsTableOrderingComposer,
      $$MilkRecordsTableAnnotationComposer,
      $$MilkRecordsTableCreateCompanionBuilder,
      $$MilkRecordsTableUpdateCompanionBuilder,
      (MilkRecordRow, $$MilkRecordsTableReferences),
      MilkRecordRow,
      PrefetchHooks Function({bool milkStatusEventsRefs, bool milkFoodTagsRefs})
    >;
typedef $$MilkStatusEventsTableCreateCompanionBuilder =
    MilkStatusEventsCompanion Function({
      required String id,
      required String milkId,
      required MilkStatusEventType type,
      required DateTime occurredAtUtc,
      Value<MilkStatus?> fromStatus,
      required MilkStatus toStatus,
      Value<String> metadataJson,
      Value<int> rowid,
    });
typedef $$MilkStatusEventsTableUpdateCompanionBuilder =
    MilkStatusEventsCompanion Function({
      Value<String> id,
      Value<String> milkId,
      Value<MilkStatusEventType> type,
      Value<DateTime> occurredAtUtc,
      Value<MilkStatus?> fromStatus,
      Value<MilkStatus> toStatus,
      Value<String> metadataJson,
      Value<int> rowid,
    });

final class $$MilkStatusEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MilkStatusEventsTable,
          MilkStatusEventRow
        > {
  $$MilkStatusEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MilkRecordsTable _milkIdTable(_$AppDatabase db) => db.milkRecords
      .createAlias('milk_status_events__milk_id__milk_records__id');

  $$MilkRecordsTableProcessedTableManager get milkId {
    final $_column = $_itemColumn<String>('milk_id')!;

    final manager = $$MilkRecordsTableTableManager(
      $_db,
      $_db.milkRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_milkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MilkStatusEventsTableFilterComposer
    extends Composer<_$AppDatabase, $MilkStatusEventsTable> {
  $$MilkStatusEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    MilkStatusEventType,
    MilkStatusEventType,
    String
  >
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MilkStatus?, MilkStatus, String>
  get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MilkStatus, MilkStatus, String> get toStatus =>
      $composableBuilder(
        column: $table.toStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  $$MilkRecordsTableFilterComposer get milkId {
    final $$MilkRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milkId,
      referencedTable: $db.milkRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkRecordsTableFilterComposer(
            $db: $db,
            $table: $db.milkRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilkStatusEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $MilkStatusEventsTable> {
  $$MilkStatusEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$MilkRecordsTableOrderingComposer get milkId {
    final $$MilkRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milkId,
      referencedTable: $db.milkRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.milkRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilkStatusEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MilkStatusEventsTable> {
  $$MilkStatusEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MilkStatusEventType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MilkStatus?, String> get fromStatus =>
      $composableBuilder(
        column: $table.fromStatus,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<MilkStatus, String> get toStatus =>
      $composableBuilder(column: $table.toStatus, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  $$MilkRecordsTableAnnotationComposer get milkId {
    final $$MilkRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milkId,
      referencedTable: $db.milkRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.milkRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilkStatusEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilkStatusEventsTable,
          MilkStatusEventRow,
          $$MilkStatusEventsTableFilterComposer,
          $$MilkStatusEventsTableOrderingComposer,
          $$MilkStatusEventsTableAnnotationComposer,
          $$MilkStatusEventsTableCreateCompanionBuilder,
          $$MilkStatusEventsTableUpdateCompanionBuilder,
          (MilkStatusEventRow, $$MilkStatusEventsTableReferences),
          MilkStatusEventRow,
          PrefetchHooks Function({bool milkId})
        > {
  $$MilkStatusEventsTableTableManager(
    _$AppDatabase db,
    $MilkStatusEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MilkStatusEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MilkStatusEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MilkStatusEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> milkId = const Value.absent(),
                Value<MilkStatusEventType> type = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<MilkStatus?> fromStatus = const Value.absent(),
                Value<MilkStatus> toStatus = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilkStatusEventsCompanion(
                id: id,
                milkId: milkId,
                type: type,
                occurredAtUtc: occurredAtUtc,
                fromStatus: fromStatus,
                toStatus: toStatus,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String milkId,
                required MilkStatusEventType type,
                required DateTime occurredAtUtc,
                Value<MilkStatus?> fromStatus = const Value.absent(),
                required MilkStatus toStatus,
                Value<String> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilkStatusEventsCompanion.insert(
                id: id,
                milkId: milkId,
                type: type,
                occurredAtUtc: occurredAtUtc,
                fromStatus: fromStatus,
                toStatus: toStatus,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MilkStatusEventsTable, MilkStatusEventRow>(
                    table,
                  ),
                  $$MilkStatusEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({milkId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (milkId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.milkId,
                        referencedTable: $$MilkStatusEventsTableReferences
                            ._milkIdTable(db),
                        referencedColumn: $$MilkStatusEventsTableReferences
                            ._milkIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MilkStatusEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilkStatusEventsTable,
      MilkStatusEventRow,
      $$MilkStatusEventsTableFilterComposer,
      $$MilkStatusEventsTableOrderingComposer,
      $$MilkStatusEventsTableAnnotationComposer,
      $$MilkStatusEventsTableCreateCompanionBuilder,
      $$MilkStatusEventsTableUpdateCompanionBuilder,
      (MilkStatusEventRow, $$MilkStatusEventsTableReferences),
      MilkStatusEventRow,
      PrefetchHooks Function({bool milkId})
    >;
typedef $$FoodTagsTableCreateCompanionBuilder = FoodTagsCompanion Function({
  required String id,
  required String name,
  required DateTime createdAtUtc,
  required DateTime updatedAtUtc,
  Value<DateTime?> lastUsedAtUtc,
  Value<int> useCount,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$FoodTagsTableUpdateCompanionBuilder = FoodTagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAtUtc,
  Value<DateTime> updatedAtUtc,
  Value<DateTime?> lastUsedAtUtc,
  Value<int> useCount,
  Value<bool> isActive,
  Value<int> rowid,
});

final class $$FoodTagsTableReferences
    extends BaseReferences<_$AppDatabase, $FoodTagsTable, FoodTagRow> {
  $$FoodTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MilkFoodTagsTable, List<MilkFoodTagRow>>
  _milkFoodTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.milkFoodTags,
    aliasName: 'food_tags__id__milk_food_tags__food_tag_id',
  );

  $$MilkFoodTagsTableProcessedTableManager get milkFoodTagsRefs {
    final manager = $$MilkFoodTagsTableTableManager(
      $_db,
      $_db.milkFoodTags,
    ).filter((f) => f.foodTagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_milkFoodTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoodTagsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodTagsTable> {
  $$FoodTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAtUtc => $composableBuilder(
    column: $table.lastUsedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get useCount => $composableBuilder(
    column: $table.useCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> milkFoodTagsRefs(
    Expression<bool> Function($$MilkFoodTagsTableFilterComposer f) f,
  ) {
    final $$MilkFoodTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milkFoodTags,
      getReferencedColumn: (t) => t.foodTagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkFoodTagsTableFilterComposer(
            $db: $db,
            $table: $db.milkFoodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodTagsTable> {
  $$FoodTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAtUtc => $composableBuilder(
    column: $table.lastUsedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get useCount => $composableBuilder(
    column: $table.useCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodTagsTable> {
  $$FoodTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUsedAtUtc => $composableBuilder(
    column: $table.lastUsedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get useCount =>
      $composableBuilder(column: $table.useCount, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> milkFoodTagsRefs<T extends Object>(
    Expression<T> Function($$MilkFoodTagsTableAnnotationComposer a) f,
  ) {
    final $$MilkFoodTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milkFoodTags,
      getReferencedColumn: (t) => t.foodTagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkFoodTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.milkFoodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodTagsTable,
          FoodTagRow,
          $$FoodTagsTableFilterComposer,
          $$FoodTagsTableOrderingComposer,
          $$FoodTagsTableAnnotationComposer,
          $$FoodTagsTableCreateCompanionBuilder,
          $$FoodTagsTableUpdateCompanionBuilder,
          (FoodTagRow, $$FoodTagsTableReferences),
          FoodTagRow,
          PrefetchHooks Function({bool milkFoodTagsRefs})
        > {
  $$FoodTagsTableTableManager(_$AppDatabase db, $FoodTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<DateTime?> lastUsedAtUtc = const Value.absent(),
                Value<int> useCount = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodTagsCompanion(
                id: id,
                name: name,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                lastUsedAtUtc: lastUsedAtUtc,
                useCount: useCount,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<DateTime?> lastUsedAtUtc = const Value.absent(),
                Value<int> useCount = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodTagsCompanion.insert(
                id: id,
                name: name,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                lastUsedAtUtc: lastUsedAtUtc,
                useCount: useCount,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodTagsTable, FoodTagRow>(table),
                  $$FoodTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({milkFoodTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (milkFoodTagsRefs) db.milkFoodTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (milkFoodTagsRefs)
                    await $_getPrefetchedData<
                      FoodTagRow,
                      $FoodTagsTable,
                      MilkFoodTagRow
                    >(
                      currentTable: table,
                      referencedTable: $$FoodTagsTableReferences
                          ._milkFoodTagsRefsTable(db),
                      managerFromTypedResult: (p0) => $$FoodTagsTableReferences(
                        db,
                        table,
                        p0,
                      ).milkFoodTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.foodTagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoodTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodTagsTable,
      FoodTagRow,
      $$FoodTagsTableFilterComposer,
      $$FoodTagsTableOrderingComposer,
      $$FoodTagsTableAnnotationComposer,
      $$FoodTagsTableCreateCompanionBuilder,
      $$FoodTagsTableUpdateCompanionBuilder,
      (FoodTagRow, $$FoodTagsTableReferences),
      FoodTagRow,
      PrefetchHooks Function({bool milkFoodTagsRefs})
    >;
typedef $$MilkFoodTagsTableCreateCompanionBuilder =
    MilkFoodTagsCompanion Function({
      required String milkId,
      required String foodTagId,
      Value<int> rowid,
    });
typedef $$MilkFoodTagsTableUpdateCompanionBuilder =
    MilkFoodTagsCompanion Function({
      Value<String> milkId,
      Value<String> foodTagId,
      Value<int> rowid,
    });

final class $$MilkFoodTagsTableReferences
    extends BaseReferences<_$AppDatabase, $MilkFoodTagsTable, MilkFoodTagRow> {
  $$MilkFoodTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MilkRecordsTable _milkIdTable(_$AppDatabase db) =>
      db.milkRecords.createAlias('milk_food_tags__milk_id__milk_records__id');

  $$MilkRecordsTableProcessedTableManager get milkId {
    final $_column = $_itemColumn<String>('milk_id')!;

    final manager = $$MilkRecordsTableTableManager(
      $_db,
      $_db.milkRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_milkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FoodTagsTable _foodTagIdTable(_$AppDatabase db) =>
      db.foodTags.createAlias('milk_food_tags__food_tag_id__food_tags__id');

  $$FoodTagsTableProcessedTableManager get foodTagId {
    final $_column = $_itemColumn<String>('food_tag_id')!;

    final manager = $$FoodTagsTableTableManager(
      $_db,
      $_db.foodTags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodTagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MilkFoodTagsTableFilterComposer
    extends Composer<_$AppDatabase, $MilkFoodTagsTable> {
  $$MilkFoodTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MilkRecordsTableFilterComposer get milkId {
    final $$MilkRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milkId,
      referencedTable: $db.milkRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkRecordsTableFilterComposer(
            $db: $db,
            $table: $db.milkRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodTagsTableFilterComposer get foodTagId {
    final $$FoodTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodTagId,
      referencedTable: $db.foodTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodTagsTableFilterComposer(
            $db: $db,
            $table: $db.foodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilkFoodTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $MilkFoodTagsTable> {
  $$MilkFoodTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MilkRecordsTableOrderingComposer get milkId {
    final $$MilkRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milkId,
      referencedTable: $db.milkRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.milkRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodTagsTableOrderingComposer get foodTagId {
    final $$FoodTagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodTagId,
      referencedTable: $db.foodTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodTagsTableOrderingComposer(
            $db: $db,
            $table: $db.foodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilkFoodTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MilkFoodTagsTable> {
  $$MilkFoodTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MilkRecordsTableAnnotationComposer get milkId {
    final $$MilkRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milkId,
      referencedTable: $db.milkRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilkRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.milkRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodTagsTableAnnotationComposer get foodTagId {
    final $$FoodTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodTagId,
      referencedTable: $db.foodTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.foodTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilkFoodTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilkFoodTagsTable,
          MilkFoodTagRow,
          $$MilkFoodTagsTableFilterComposer,
          $$MilkFoodTagsTableOrderingComposer,
          $$MilkFoodTagsTableAnnotationComposer,
          $$MilkFoodTagsTableCreateCompanionBuilder,
          $$MilkFoodTagsTableUpdateCompanionBuilder,
          (MilkFoodTagRow, $$MilkFoodTagsTableReferences),
          MilkFoodTagRow,
          PrefetchHooks Function({bool milkId, bool foodTagId})
        > {
  $$MilkFoodTagsTableTableManager(_$AppDatabase db, $MilkFoodTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MilkFoodTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MilkFoodTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MilkFoodTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> milkId = const Value.absent(),
                Value<String> foodTagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilkFoodTagsCompanion(
                milkId: milkId,
                foodTagId: foodTagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String milkId,
                required String foodTagId,
                Value<int> rowid = const Value.absent(),
              }) => MilkFoodTagsCompanion.insert(
                milkId: milkId,
                foodTagId: foodTagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MilkFoodTagsTable, MilkFoodTagRow>(table),
                  $$MilkFoodTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({milkId = false, foodTagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (milkId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.milkId,
                        referencedTable: $$MilkFoodTagsTableReferences
                            ._milkIdTable(db),
                        referencedColumn: $$MilkFoodTagsTableReferences
                            ._milkIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (foodTagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.foodTagId,
                        referencedTable: $$MilkFoodTagsTableReferences
                            ._foodTagIdTable(db),
                        referencedColumn: $$MilkFoodTagsTableReferences
                            ._foodTagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MilkFoodTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilkFoodTagsTable,
      MilkFoodTagRow,
      $$MilkFoodTagsTableFilterComposer,
      $$MilkFoodTagsTableOrderingComposer,
      $$MilkFoodTagsTableAnnotationComposer,
      $$MilkFoodTagsTableCreateCompanionBuilder,
      $$MilkFoodTagsTableUpdateCompanionBuilder,
      (MilkFoodTagRow, $$MilkFoodTagsTableReferences),
      MilkFoodTagRow,
      PrefetchHooks Function({bool milkId, bool foodTagId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String valueJson,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> valueJson,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                valueJson: valueJson,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                valueJson: valueJson,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MilkRecordsTableTableManager get milkRecords =>
      $$MilkRecordsTableTableManager(_db, _db.milkRecords);
  $$MilkStatusEventsTableTableManager get milkStatusEvents =>
      $$MilkStatusEventsTableTableManager(_db, _db.milkStatusEvents);
  $$FoodTagsTableTableManager get foodTags =>
      $$FoodTagsTableTableManager(_db, _db.foodTags);
  $$MilkFoodTagsTableTableManager get milkFoodTags =>
      $$MilkFoodTagsTableTableManager(_db, _db.milkFoodTags);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
