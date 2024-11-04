module.exports = {
  devServer: {
    setupMiddlewares: function (middlewares, devServer) {
      devServer.app.use((req, res, next) => {
        console.log(`Request received: ${req.method} ${req.url}`);
        next();
      });
      return middlewares;
    },
  },
};