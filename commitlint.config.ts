// oxlint-disable import/no-anonymous-default-export import/no-default-export

enum Level {
  // oxlint-disable-next-line no-magic-numbers
  DISABLE = 0,
  // oxlint-disable-next-line no-magic-numbers
  WARN = 1,
  // oxlint-disable-next-line no-magic-numbers
  ERROR = 2,
}

export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'scope-empty': [Level.ERROR, 'never'],
  },
};
