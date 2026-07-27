export const context = {
  repo: {
    owner: 'mock-owner',
    repo: 'mock-repo',
  },
};

export const getOctokit = jest.fn(() => ({
  rest: {
    repos: {
      listTags: jest.fn(),
      compareCommits: jest.fn(),
    },
    git: {
      createTag: jest.fn(),
      createRef: jest.fn(),
    },
  },
}));
