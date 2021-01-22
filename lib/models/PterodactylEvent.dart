import 'dart:convert';

PterodactylWebSocketEvent pterodactylWebSocketEventFromJson(String str) => PterodactylWebSocketEvent.fromJson(json.decode(str));

String pterodactylWebSocketEventToJson(PterodactylWebSocketEvent data) => json.encode(data.toJson());

class PterodactylWebSocketEvent {
  PterodactylWebSocketEvent({
    this.event,
    this.args,
  });

  String event;
  List<String> args;

  factory PterodactylWebSocketEvent.fromJson(Map<String, dynamic> json) => PterodactylWebSocketEvent(
    event: json["event"],
    args: json["args"] == null ? null : List<String>.from(json["args"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "event": event,
    "args": args == null ? null : List<dynamic>.from(args.map((x) => x)),
  };
}
