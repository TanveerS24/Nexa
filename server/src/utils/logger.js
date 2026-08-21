const util = require('util');

// ANSI Color Codes for terminal readability
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m',
  gray: '\x1b[90m',
};

const sensitiveKeys = new Set([
  'password',
  'newpassword',
  'oldpassword',
  'token',
  'accesstoken',
  'refreshtoken',
  'authorization',
  'secret',
  'apikey',
  'privatekey',
  'service_role_key',
  'service_role',
  'anon_key',
]);

/**
 * Recursively masks sensitive fields in objects for safe logging
 */
function sanitize(obj, depth = 0) {
  if (depth > 5 || obj === null || obj === undefined) return obj;
  if (typeof obj !== 'object') return obj;

  if (Array.isArray(obj)) {
    return obj.map((item) => sanitize(item, depth + 1));
  }

  const sanitized = {};
  for (const [key, value] of Object.entries(obj)) {
    const lowerKey = key.toLowerCase().replace(/[-_]/g, '');
    if (sensitiveKeys.has(lowerKey)) {
      sanitized[key] = '***[REDACTED]***';
    } else if (typeof value === 'object' && value !== null) {
      sanitized[key] = sanitize(value, depth + 1);
    } else {
      sanitized[key] = value;
    }
  }
  return sanitized;
}

/**
 * Format argument into readable string or pretty JSON
 */
function formatArg(arg) {
  if (arg instanceof Error) {
    return `${colors.red}${arg.stack || arg.message}${colors.reset}`;
  }
  if (typeof arg === 'object' && arg !== null) {
    try {
      const sanitized = sanitize(arg);
      return util.inspect(sanitized, { depth: 4, colors: true, compact: false });
    } catch {
      return String(arg);
    }
  }
  return String(arg);
}

function formatMessage(level, color, message, args) {
  const timestamp = new Date().toISOString();
  const tag = `${color}[${level}]${colors.reset}`;
  const time = `${colors.gray}[${timestamp}]${colors.reset}`;
  const formattedArgs = args.length > 0 ? ' ' + args.map(formatArg).join(' ') : '';
  return `${tag} ${time} ${message}${formattedArgs}`;
}

const logger = {
  info: (message, ...args) => {
    console.log(formatMessage('INFO', colors.green, message, args));
  },
  http: (message, ...args) => {
    console.log(formatMessage('HTTP', colors.cyan, message, args));
  },
  warn: (message, ...args) => {
    console.warn(formatMessage('WARN', colors.yellow, message, args));
  },
  error: (message, ...args) => {
    console.error(formatMessage('ERROR', colors.red, message, args));
  },
  debug: (message, ...args) => {
    if (process.env.NODE_ENV !== 'production' || process.env.DEBUG === 'true') {
      console.log(formatMessage('DEBUG', colors.magenta, message, args));
    }
  },
  sanitize,
};

module.exports = logger;
