class ErrorResponse {
  ErrorResponse({
    required this.estado,
    required this.codigo,
    required this.mensaje,
    required this.ruta,
    required this.fecha,
    required this.subErrores,
  });
  late final dynamic estado;
  late final dynamic codigo;
  late final String mensaje;
  late final String ruta;
  late final String fecha;
  late final List<SubErrores> subErrores;
  
  ErrorResponse.fromJson(Map<String, dynamic> json){
    estado = json['estado'];
    codigo = json['codigo'];
    mensaje = json['mensaje']!=null?json['mensaje']:"";
    ruta = json['ruta'];
    fecha = json['fecha'];
    subErrores = List.from(json['subErrores']).map((e)=>SubErrores.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['estado'] = estado;
    _data['codigo'] = codigo;
    _data['mensaje'] = mensaje;
    _data['ruta'] = ruta;
    _data['fecha'] = fecha;
    _data['subErrores'] = subErrores.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class SubErrores {
  SubErrores({
    required this.objeto,
    required this.mensaje,
     this.campo,
  });
  late final String objeto;
  late final String mensaje;
  late String? campo;
  
  SubErrores.fromJson(Map<String, dynamic> json){
    objeto = json['objeto']!=null?json['objeto']:"";
    mensaje = json['mensaje']!=null?json['mensaje']:"";
    campo = json['campo']!=null?json['campo']:"";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['objeto'] = objeto;
    _data['mensaje'] = mensaje;
    _data['campo'] = campo;
    return _data;
  }
}