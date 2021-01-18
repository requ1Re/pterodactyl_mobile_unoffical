// To parse this JSON data, do
//
//     final serverResources = serverResourcesFromJson(jsonString);

import 'dart:convert';

ServerResources serverResourcesFromJson(String str) => ServerResources.fromJson(json.decode(str));

String serverResourcesToJson(ServerResources data) => json.encode(data.toJson());

class ServerResources {
  ServerResources({
    this.object,
    this.attributes,
  });

  String object;
  Attributes attributes;

  factory ServerResources.fromJson(Map<String, dynamic> json) => ServerResources(
    object: json["object"],
    attributes: Attributes.fromJson(json["attributes"]),
  );

  Map<String, dynamic> toJson() => {
    "object": object,
    "attributes": attributes.toJson(),
  };
}

class Attributes {
  Attributes({
    this.currentState,
    this.isSuspended,
    this.resources,
  });

  String currentState;
  bool isSuspended;
  Resources resources;

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    currentState: json["current_state"],
    isSuspended: json["is_suspended"],
    resources: Resources.fromJson(json["resources"]),
  );

  Map<String, dynamic> toJson() => {
    "current_state": currentState,
    "is_suspended": isSuspended,
    "resources": resources.toJson(),
  };
}

class Resources {
  Resources({
    this.memoryBytes,
    this.cpuAbsolute,
    this.diskBytes,
    this.networkRxBytes,
    this.networkTxBytes,
  });

  dynamic memoryBytes;
  dynamic cpuAbsolute;
  dynamic diskBytes;
  dynamic networkRxBytes;
  dynamic networkTxBytes;

  factory Resources.fromJson(Map<String, dynamic> json) => Resources(
    memoryBytes: json["memory_bytes"],
    cpuAbsolute: json["cpu_absolute"],
    diskBytes: json["disk_bytes"],
    networkRxBytes: json["network_rx_bytes"],
    networkTxBytes: json["network_tx_bytes"],
  );

  Map<String, dynamic> toJson() => {
    "memory_bytes": memoryBytes,
    "cpu_absolute": cpuAbsolute,
    "disk_bytes": diskBytes,
    "network_rx_bytes": networkRxBytes,
    "network_tx_bytes": networkTxBytes,
  };
}
