class AppConstants {
  // 应用版本
  static String appVersion = '1.0.0';

  // 设备信息收集API
  static String privacyAPI = 'https://privacy.claret.space/api';

  // 可用模型
  static List<String> models = [
    'qwen-max',
    'qwen-plus',
    'qwen-turbo',
    'qwen-long',
    'GPT-4o',
    'GPT-4o mini',
    'GLM-4-Air',
    'GLM-4-Plus',
  ];

  // 千问 API
  static String QwenAPI =
      'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions';

  // OPENAI API
  static String OpenAIAPI = 'https://api.openai.com/v1/chat/completions';

  // 智谱 API
  static String ZhipuAPI =
      'https://open.bigmodel.cn/api/paas/v4/chat/completions';
}
