const path = require('path');

/** @type {import('next').NextConfig} */
module.exports = {
  turbopack: {
    // monorepo root (classmate/)
    root: path.join(__dirname, '../..'),
  },
};
