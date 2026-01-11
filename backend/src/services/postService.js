import * as postRepo from "../repositories/postRepository.js";
import * as error from "../utils/error.js";

export const createPostService = async (payload) => {
  const { authorId, content, images = [], video = null, visibility } = payload;

  // validate noi dung
  const hasText = !!content?.trim();
  const hasImages = images.length > 0;
  const hasVideo = !!video;

  if (!hasText && !hasImages && !hasVideo) {
    throw new error.BadRequestError("Post cannot be empty");
  }

  // khong cho vua anh vua video
  if (hasImages && hasVideo) {
    throw new error.BadRequestError(
      "Post cannot contain both images and video"
    );
  }

  // chuan hoa payload
  const postPayload = {
    authorId,
    content: hasText ? content.trim() : "",
    images: hasImages ? images : [],
    video: hasVideo ? video : null,
    visibility: visibility || "public",
  };

  return await postRepo.createPost(postPayload);
};

export const updatePostService = async (postId, payload, currentUser) => {
  const post = await postRepo.findPostById(postId);
  if (!post) {
    throw new error.NotFoundError("Cannot find this post");
  }

  // check quyen sua
  // chi tac gia hoac admin moi sua duoc
  const isOwner = post.authorId.toString() === currentUser.id;
  const isAdmin = currentUser.role === "admin";

  if (!isOwner && !isAdmin) {
    throw new error.ForbiddenError("You are not allowed to edit this post");
  }

  const { content, images = [], video = null, visibility } = payload;

  const hasText = !!content?.trim();
  const hasImages = images.length > 0;
  const hasVideo = !!video;

  if (!hasText && !hasImages && !hasVideo) {
    throw new error.BadRequestError("Post cannot be empty");
  }

  // khong cho vua anh vua video
  if (hasImages && hasVideo) {
    throw new error.BadRequestError(
      "Post cannot contain both images and video"
    );
  }

  const updatePayload = {
    content: hasText ? content.trim() : "",
    images: hasImages ? images : [],
    video: hasVideo ? video : null,
  };

  if (visibility) {
    updatePayload.visibility = visibility;
  }

  return await postRepo.updatePost(postId, updatePayload);
};

export const softDeletePostService = async (postId, currentUser) => {
  const post = await postRepo.findPostById(postId);
  if (!post) {
    throw new error.NotFoundError("Cannot find this post");
  }

  const isOwner = post.authorId.toString() === currentUser.id;
  const isAdmin = currentUser.role === "admin";

  if (!isOwner && !isAdmin) {
    throw new error.ForbiddenError("You are not allowed to delete this post");
  }

  return postRepo.softDeletePost(postId, currentUser.id);
};

export const hardDeletePostService = async (postId, currentUser) => {
  // chi admin moi duoc xoa
  if (currentUser.role !== "admin") {
    throw new error.ForbiddenError("Admin only");
  }

  // kiem tra ton tai
  const post = await postRepo.findPostById(postId);
  if (!post) {
    throw new error.NotFoundError("Cannot find this post");
  }

  await postRepo.hardDeletePost(postId);

  return { success: true };
};

export const getFeedService = async (query) => {
  return await postRepo.getFeed(query);
};
