class MqttGenerics {
  MqttGenerics._();

  static final MqttGenerics instance = MqttGenerics._();

  // Convert our Note to JSON to make it easier when we store it in the database
  String publishUserTopic(String userId){
    return "users/$userId";
  }

  String subscribeUserTopic(String userId){
    return "users/$userId";
  }
  String subscribeAllUsersTopic(){
    return "users/all";
  }
}
