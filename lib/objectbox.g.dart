// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again
// with `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'features/knowledge_base/data/entities/vector_collection_entity.dart';
import 'features/knowledge_base/data/entities/vector_document_entity.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(1, 4459934307494889475),
      name: 'VectorCollectionEntity',
      lastPropertyId: const obx_int.IdUid(9, 4459668095892156696),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 3248838367420270523),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 7874956072637413074),
            name: 'collectionName',
            type: 9,
            flags: 2080,
            indexId: const obx_int.IdUid(1, 1307349783517777265)),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 8392636195095174556),
            name: 'vectorDimension',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 1507422902658866108),
            name: 'description',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 6097884907819546080),
            name: 'documentCount',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 4941899692888055682),
            name: 'createdAt',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 2544437008335576318),
            name: 'updatedAt',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 8556303806851248524),
            name: 'metadata',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(9, 4459668095892156696),
            name: 'isEnabled',
            type: 1,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 8430527117949909134),
      name: 'VectorDocumentEntity',
      lastPropertyId: const obx_int.IdUid(7, 2929257100603542662),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 8880651477977259009),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 1778479024197302793),
            name: 'documentId',
            type: 9,
            flags: 2080,
            indexId: const obx_int.IdUid(2, 2567439885417587416)),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 872630008812898502),
            name: 'collectionName',
            type: 9,
            flags: 2048,
            indexId: const obx_int.IdUid(3, 870606289129943582)),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 2390889748652821694),
            name: 'vector',
            type: 28,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 7990644778222772372),
            name: 'metadata',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 5045478097231967448),
            name: 'createdAt',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 2929257100603542662),
            name: 'updatedAt',
            type: 10,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[])
];

/// Shortcut for [obx.Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [obx.Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [obx.Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(2, 8430527117949909134),
      lastIndexId: const obx_int.IdUid(3, 870606289129943582),
      lastRelationId: const obx_int.IdUid(0, 0),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    VectorCollectionEntity: obx_int.EntityDefinition<VectorCollectionEntity>(
        model: _entities[0],
        toOneRelations: (VectorCollectionEntity object) => [],
        toManyRelations: (VectorCollectionEntity object) => {},
        getId: (VectorCollectionEntity object) => object.id,
        setId: (VectorCollectionEntity object, int id) {
          object.id = id;
        },
        objectToFB: (VectorCollectionEntity object, fb.Builder fbb) {
          final collectionNameOffset = fbb.writeString(object.collectionName);
          final descriptionOffset = object.description == null
              ? null
              : fbb.writeString(object.description!);
          final metadataOffset = object.metadata == null
              ? null
              : fbb.writeString(object.metadata!);
          fbb.startTable(10);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, collectionNameOffset);
          fbb.addInt64(2, object.vectorDimension);
          fbb.addOffset(3, descriptionOffset);
          fbb.addInt64(4, object.documentCount);
          fbb.addInt64(5, object.createdAt.millisecondsSinceEpoch);
          fbb.addInt64(6, object.updatedAt.millisecondsSinceEpoch);
          fbb.addOffset(7, metadataOffset);
          fbb.addBool(8, object.isEnabled);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final collectionNameParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 6, '');
          final vectorDimensionParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0);
          final descriptionParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGetNullable(buffer, rootOffset, 10);
          final documentCountParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0);
          final createdAtParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0));
          final updatedAtParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 16, 0));
          final metadataParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 18);
          final isEnabledParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 20, false);
          final object = VectorCollectionEntity(
              collectionName: collectionNameParam,
              vectorDimension: vectorDimensionParam,
              description: descriptionParam,
              documentCount: documentCountParam,
              createdAt: createdAtParam,
              updatedAt: updatedAtParam,
              metadata: metadataParam,
              isEnabled: isEnabledParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        }),
    VectorDocumentEntity: obx_int.EntityDefinition<VectorDocumentEntity>(
        model: _entities[1],
        toOneRelations: (VectorDocumentEntity object) => [],
        toManyRelations: (VectorDocumentEntity object) => {},
        getId: (VectorDocumentEntity object) => object.id,
        setId: (VectorDocumentEntity object, int id) {
          object.id = id;
        },
        objectToFB: (VectorDocumentEntity object, fb.Builder fbb) {
          final documentIdOffset = fbb.writeString(object.documentId);
          final collectionNameOffset = fbb.writeString(object.collectionName);
          final vectorOffset = object.vector == null
              ? null
              : fbb.writeListFloat32(object.vector!);
          final metadataOffset = object.metadata == null
              ? null
              : fbb.writeString(object.metadata!);
          fbb.startTable(8);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, documentIdOffset);
          fbb.addOffset(2, collectionNameOffset);
          fbb.addOffset(3, vectorOffset);
          fbb.addOffset(4, metadataOffset);
          fbb.addInt64(5, object.createdAt.millisecondsSinceEpoch);
          fbb.addInt64(6, object.updatedAt.millisecondsSinceEpoch);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final documentIdParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final collectionNameParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, '');
          final vectorParam =
              const fb.ListReader<double>(fb.Float32Reader(), lazy: false)
                  .vTableGetNullable(buffer, rootOffset, 10);
          final metadataParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 12);
          final createdAtParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0));
          final updatedAtParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 16, 0));
          final object = VectorDocumentEntity(
              documentId: documentIdParam,
              collectionName: collectionNameParam,
              vector: vectorParam,
              metadata: metadataParam,
              createdAt: createdAtParam,
              updatedAt: updatedAtParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [VectorCollectionEntity] entity fields to define ObjectBox queries.
class VectorCollectionEntity_ {
  /// See [VectorCollectionEntity.id].
  static final id = obx.QueryIntegerProperty<VectorCollectionEntity>(
      _entities[0].properties[0]);

  /// See [VectorCollectionEntity.collectionName].
  static final collectionName = obx.QueryStringProperty<VectorCollectionEntity>(
      _entities[0].properties[1]);

  /// See [VectorCollectionEntity.vectorDimension].
  static final vectorDimension =
      obx.QueryIntegerProperty<VectorCollectionEntity>(
          _entities[0].properties[2]);

  /// See [VectorCollectionEntity.description].
  static final description = obx.QueryStringProperty<VectorCollectionEntity>(
      _entities[0].properties[3]);

  /// See [VectorCollectionEntity.documentCount].
  static final documentCount = obx.QueryIntegerProperty<VectorCollectionEntity>(
      _entities[0].properties[4]);

  /// See [VectorCollectionEntity.createdAt].
  static final createdAt =
      obx.QueryDateProperty<VectorCollectionEntity>(_entities[0].properties[5]);

  /// See [VectorCollectionEntity.updatedAt].
  static final updatedAt =
      obx.QueryDateProperty<VectorCollectionEntity>(_entities[0].properties[6]);

  /// See [VectorCollectionEntity.metadata].
  static final metadata = obx.QueryStringProperty<VectorCollectionEntity>(
      _entities[0].properties[7]);

  /// See [VectorCollectionEntity.isEnabled].
  static final isEnabled = obx.QueryBooleanProperty<VectorCollectionEntity>(
      _entities[0].properties[8]);
}

/// [VectorDocumentEntity] entity fields to define ObjectBox queries.
class VectorDocumentEntity_ {
  /// See [VectorDocumentEntity.id].
  static final id = obx.QueryIntegerProperty<VectorDocumentEntity>(
      _entities[1].properties[0]);

  /// See [VectorDocumentEntity.documentId].
  static final documentId =
      obx.QueryStringProperty<VectorDocumentEntity>(_entities[1].properties[1]);

  /// See [VectorDocumentEntity.collectionName].
  static final collectionName =
      obx.QueryStringProperty<VectorDocumentEntity>(_entities[1].properties[2]);

  /// See [VectorDocumentEntity.vector].
  static final vector = obx.QueryDoubleVectorProperty<VectorDocumentEntity>(
      _entities[1].properties[3]);

  /// See [VectorDocumentEntity.metadata].
  static final metadata =
      obx.QueryStringProperty<VectorDocumentEntity>(_entities[1].properties[4]);

  /// See [VectorDocumentEntity.createdAt].
  static final createdAt =
      obx.QueryDateProperty<VectorDocumentEntity>(_entities[1].properties[5]);

  /// See [VectorDocumentEntity.updatedAt].
  static final updatedAt =
      obx.QueryDateProperty<VectorDocumentEntity>(_entities[1].properties[6]);
}
