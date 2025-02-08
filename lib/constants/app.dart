class AppConstants {
  // 应用版本
  static String appVersion = '1.0.0';

  // DeepSeek 模型
  static List<String> dsModels = ['deepseek-chat', 'deepseek-reasoner'];

  // Qwen (千问) 模型
  static List<String> qwenModels = [
    'qwen-max',
    'qwen-plus',
    'qwen-turbo',
    'qwen-long'
  ];

  // OpenAI 模型
  static List<String> openAIModels = ['GPT-4o', 'GPT-4o mini'];

  // 智谱 (GLM) 模型
  static List<String> zhipuModels = ['glm-4-air', 'glm-4-plus'];

  // 统一获取所有模型
  static List<String> get models =>
      dsModels + qwenModels + openAIModels + zhipuModels;

  // 根据模型名称获取 API 地址
  static String getAPI(String model) {
    if (dsModels.contains(model)) return DSAPI;
    if (qwenModels.contains(model)) return QwenAPI;
    if (openAIModels.contains(model)) return OpenAIAPI;
    if (zhipuModels.contains(model)) return ZhipuAPI;
    return '';
  }

  // 千问 API
  static String QwenAPI =
      'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions';

  // OPENAI API
  static String OpenAIAPI = 'https://api.openai.com/v1/chat/completions';

  // 智谱 API
  static String ZhipuAPI =
      'https://open.bigmodel.cn/api/paas/v4/chat/completions';

  // Deepseek API
  static String DSAPI = 'https://api.deepseek.com/chat/completions';
}
