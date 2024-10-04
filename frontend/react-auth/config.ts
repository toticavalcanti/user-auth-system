// frontend/react-auth/src/config.ts
import process from 'process';
// Define a interface para as variáveis de ambiente
interface EnvConfig {
    REACT_APP_API_URL?: string;
    REACT_APP_FEATURE_FLAG_NEW_UI?: string;
    REACT_APP_LOG_LEVEL?: string;
  }
  
  // Estende a interface Window para incluir _env_
  declare global {
    interface Window {
      _env_?: EnvConfig;
    }
  }
  
  // Interface para o objeto de configuração
  interface Config {
    apiUrl: string;
    featureFlagNewUi: boolean;
    logLevel: string;
  }
  
  const config: Config = {
    apiUrl: window._env_?.REACT_APP_API_URL || process.env.REACT_APP_API_URL || 'http://localhost:3000',
    featureFlagNewUi: window._env_?.REACT_APP_FEATURE_FLAG_NEW_UI === 'true' || process.env.REACT_APP_FEATURE_FLAG_NEW_UI === 'true',
    logLevel: window._env_?.REACT_APP_LOG_LEVEL || process.env.REACT_APP_LOG_LEVEL || 'error'
  };
  
  export default config;