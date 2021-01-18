// To parse this JSON data, do
//
//     final serverList = serverListFromJson(jsonString);

import 'dart:convert';

import 'package:pterodactyl_mobile/models/ServerResources.dart';

ServerList serverListFromJson(String str) => ServerList.fromJson(json.decode(str));

String serverListToJson(ServerList data) => json.encode(data.toJson());

class ServerList {
  ServerList({
    this.object,
    this.data,
    this.meta,
  });

  String object;
  List<Server> data;
  Meta meta;

  factory ServerList.fromJson(Map<String, dynamic> json) => ServerList(
    object: json["object"],
    data: List<Server>.from(json["data"].map((x) => Server.fromJson(x))),
    meta: Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "object": object,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": meta.toJson(),
  };
}

class Server {
  Server({
    this.object,
    this.attributes,
  });

  String object;
  ServerAttributes attributes;
  ServerResources resources;

  factory Server.fromJson(Map<String, dynamic> json) => Server(
    object: json["object"],
    attributes: ServerAttributes.fromJson(json["attributes"]),
  );

  Map<String, dynamic> toJson() => {
    "object": object,
    "attributes": attributes.toJson(),
  };
}

class ServerAttributes {
  ServerAttributes({
    this.serverOwner,
    this.identifier,
    this.uuid,
    this.name,
    this.node,
    this.sftpDetails,
    this.description,
    this.limits,
    this.featureLimits,
    this.isSuspended,
    this.isInstalling,
    this.relationships,
  });

  bool serverOwner;
  String identifier;
  String uuid;
  String name;
  String node;
  SftpDetails sftpDetails;
  String description;
  Limits limits;
  FeatureLimits featureLimits;
  bool isSuspended;
  bool isInstalling;
  Relationships relationships;

  factory ServerAttributes.fromJson(Map<String, dynamic> json) => ServerAttributes(
    serverOwner: json["server_owner"],
    identifier: json["identifier"],
    uuid: json["uuid"],
    name: json["name"],
    node: json["node"],
    sftpDetails: SftpDetails.fromJson(json["sftp_details"]),
    description: json["description"],
    limits: Limits.fromJson(json["limits"]),
    featureLimits: FeatureLimits.fromJson(json["feature_limits"]),
    isSuspended: json["is_suspended"],
    isInstalling: json["is_installing"],
    relationships: Relationships.fromJson(json["relationships"]),
  );

  Map<String, dynamic> toJson() => {
    "server_owner": serverOwner,
    "identifier": identifier,
    "uuid": uuid,
    "name": name,
    "node": node,
    "sftp_details": sftpDetails.toJson(),
    "description": description,
    "limits": limits.toJson(),
    "feature_limits": featureLimits.toJson(),
    "is_suspended": isSuspended,
    "is_installing": isInstalling,
    "relationships": relationships.toJson(),
  };
}

class FeatureLimits {
  FeatureLimits({
    this.databases,
    this.allocations,
    this.backups,
  });

  int databases;
  int allocations;
  int backups;

  factory FeatureLimits.fromJson(Map<String, dynamic> json) => FeatureLimits(
    databases: json["databases"],
    allocations: json["allocations"],
    backups: json["backups"],
  );

  Map<String, dynamic> toJson() => {
    "databases": databases,
    "allocations": allocations,
    "backups": backups,
  };
}

class Limits {
  Limits({
    this.memory,
    this.swap,
    this.disk,
    this.io,
    this.cpu,
  });

  int memory;
  int swap;
  int disk;
  int io;
  int cpu;

  factory Limits.fromJson(Map<String, dynamic> json) => Limits(
    memory: json["memory"],
    swap: json["swap"],
    disk: json["disk"],
    io: json["io"],
    cpu: json["cpu"],
  );

  Map<String, dynamic> toJson() => {
    "memory": memory,
    "swap": swap,
    "disk": disk,
    "io": io,
    "cpu": cpu,
  };
}

class Relationships {
  Relationships({
    this.allocations,
  });

  Allocations allocations;

  factory Relationships.fromJson(Map<String, dynamic> json) => Relationships(
    allocations: Allocations.fromJson(json["allocations"]),
  );

  Map<String, dynamic> toJson() => {
    "allocations": allocations.toJson(),
  };
}

class Allocations {
  Allocations({
    this.object,
    this.data,
  });

  String object;
  List<AllocationsData> data;

  factory Allocations.fromJson(Map<String, dynamic> json) => Allocations(
    object: json["object"],
    data: List<AllocationsData>.from(json["data"].map((x) => AllocationsData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "object": object,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class AllocationsData {
  AllocationsData({
    this.object,
    this.attributes,
  });

  String object;
  AllocationAttributes attributes;

  factory AllocationsData.fromJson(Map<String, dynamic> json) => AllocationsData(
    object: json["object"],
    attributes: AllocationAttributes.fromJson(json["attributes"]),
  );

  Map<String, dynamic> toJson() => {
    "object": object,
    "attributes": attributes.toJson(),
  };
}

class AllocationAttributes {
  AllocationAttributes({
    this.id,
    this.ip,
    this.ipAlias,
    this.port,
    this.notes,
    this.isDefault,
  });

  int id;
  String ip;
  dynamic ipAlias;
  int port;
  String notes;
  bool isDefault;

  factory AllocationAttributes.fromJson(Map<String, dynamic> json) => AllocationAttributes(
    id: json["id"],
    ip: json["ip"],
    ipAlias: json["ip_alias"],
    port: json["port"],
    notes: json["notes"] == null ? null : json["notes"],
    isDefault: json["is_default"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ip": ip,
    "ip_alias": ipAlias,
    "port": port,
    "notes": notes == null ? null : notes,
    "is_default": isDefault,
  };
}

class SftpDetails {
  SftpDetails({
    this.ip,
    this.port,
  });

  String ip;
  int port;

  factory SftpDetails.fromJson(Map<String, dynamic> json) => SftpDetails(
    ip: json["ip"],
    port: json["port"],
  );

  Map<String, dynamic> toJson() => {
    "ip": ip,
    "port": port,
  };
}

class Meta {
  Meta({
    this.pagination,
  });

  Pagination pagination;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "pagination": pagination.toJson(),
  };
}

class Pagination {
  Pagination({
    this.total,
    this.count,
    this.perPage,
    this.currentPage,
    this.totalPages,
    this.links,
  });

  int total;
  int count;
  int perPage;
  int currentPage;
  int totalPages;
  Links links;

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"],
    count: json["count"],
    perPage: json["per_page"],
    currentPage: json["current_page"],
    totalPages: json["total_pages"],
    links: Links.fromJson(json["links"]),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "count": count,
    "per_page": perPage,
    "current_page": currentPage,
    "total_pages": totalPages,
    "links": links.toJson(),
  };
}

class Links {
  Links();

  factory Links.fromJson(Map<String, dynamic> json) => Links(
  );

  Map<String, dynamic> toJson() => {
  };
}
