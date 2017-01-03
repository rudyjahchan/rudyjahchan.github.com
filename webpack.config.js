var webpack = require('webpack');
var ExtractTextPlugin = require("extract-text-webpack-plugin");
var autoprefixer = require('autoprefixer');

var cssPlugin = new ExtractTextPlugin("stylesheets/[name].css", { allChunks: true });

module.exports = {
	entry: {
		all: [ './client/javascripts/all.js', './client/stylesheets/all.scss',],
	},

	resolve: {
		root: __dirname + '/source/javascripts',
	},

	output: {
		path: './source/',
		filename: 'javascripts/[name].js',
	},

  module: {
    loaders: [
      { test: /\.jsx?$/, exclude: /node_modules/, loader: 'babel-loader'},
      { test: /\.css$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader!postcss-loader") },
      { test: /\.scss$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader!postcss-loader!sass") },
    ],
  },

  postcss: function () {
    return [autoprefixer,];
  },

  plugins: [
    new webpack.optimize.DedupePlugin(),
    cssPlugin,
    new webpack.optimize.UglifyJsPlugin({minimize: true}),
  ],
};
