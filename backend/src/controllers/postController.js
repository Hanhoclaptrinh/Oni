import * as postService from "../services/postService.js";

export const createPostHandler = async (req, res, next) => {
  try {
    const payload = {
      authorId: req.user.id,
      content: req.body.content,
      images: req.body.images,
      video: req.body.video,
      visibility: req.body.visibility,
    };

    const post = await postService.createPostService(payload);

    res.status(201).json({
      message: "Post created successfully",
      data: post,
    });
  } catch (e) {
    next(e);
  }
};

export const updatePostHandler = async (req, res, next) => {
  try {
    const postId = req.params.id;
    const payload = req.body;
    const currentUser = req.user;

    const post = await postService.updatePostService(
      postId,
      payload,
      currentUser
    );

    res.json({
      message: "Post updated successfully",
      data: post,
    });
  } catch (e) {
    next(e);
  }
};

export const softDeletePostHandler = async (req, res, next) => {
  try {
    const postId = req.params.id;
    const currentUser = req.user;

    await postService.softDeletePostService(postId, currentUser);

    res.json({
      message: "Post deleted",
    });
  } catch (e) {
    next(e);
  }
};

export const hardDeletePostHandler = async (req, res, next) => {
  try {
    const postId = req.params.id;
    const currentUser = req.user;

    await postService.hardDeletePostService(postId, currentUser);

    res.json({
      message: "Post permanently deleted",
    });
  } catch (e) {
    next(e);
  }
};

export const getFeedHandler = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    const posts = await postService.getFeedService({ page, limit });

    res.json({
      message: "Fetched feed successfully",
      data: posts,
    });
  } catch (e) {
    next(e);
  }
};

export const getUserPostsHandler = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const posts = await postService.getUserPostsService(userId);

    res.json({
      message: "Fetched user posts successfully",
      data: posts,
    });
  } catch (e) {
    next(e);
  }
};
