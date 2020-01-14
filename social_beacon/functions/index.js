const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });


exports.onCreateFollower = functions.firestore.document('/followers/{userId}/userFollowers/{followerId}').onCreate(async (snapshot, context) => {
    console.log('follower created', snapshot.data());
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // Create followed user's posts ref
    const followedUserPostsRef = admin.firestore().collection('posts').doc(userId).collection('userPosts');

    // Create following user's timeline ref
    const timelinePostsRef = admin.firestore().collection('timeline').doc(followerId).collection('timelinePosts');

    // Get followed user's posts
    const querySnapshot = await followedUserPostsRef.get();

    // Add each user post to following user's timeline
    querySnapshot.forEach(doc => {
        if (doc.exists) {
            const postId = doc.id;
            const postData = doc.data();
            timelinePostsRef.doc(postId).set()
        }
    });
});


exports.onDeleteFollower = functions.firestore.document('/followers/{userId}/userFollowers/{followerId}').onDelete(async (snapshot, context) => {
    console.log('follower deleted', snapshot.id);

    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const timelinePostsRef = admin.firestore().collection('timeline').doc(followerId).collection('timelinePosts').where('ownerId', '==', userId);
    querySnapshot = await timelinePostsRef.get();

    querySnapshot.forEach(doc => {
        if (doc.exists) {
            doc.ref.delete();
        }
    });
});


// When a post is created, add post to timeline's of each follower (of post owner)
exports.onCreatePost = functions.firestore.document('/posts/{userId}/userPosts/{postId}').onCreate(async (snapshot, context) => {
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // Get all followers of post owner
    const userFollowersRef = admin.firestore.collection('followers').doc(userId).collection('userFollowers');
    const querySnapshot = await userFollowersRef.get();

    // Add new post to each follower's timeline
    querySnapshot.forEach((doc) => {
        const followerId = doc.id;
        admin.firestore().collection('timeline').doc(followerId).collection('timelinePosts').doc(postId).set(postCreated);
    });
});


// When a post is updated, update post on timeline's of each follower (of post owner)
exports.onUpdatePost = functions.firestore.document('/posts/{userId}/userPosts/{postId}').onUpdate(async (change, context) => {
    const postUpdated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // Get all followers of post owner
    const userFollowersRef = admin.firestore.collection('followers').doc(userId).collection('userFollowers');
    const querySnapshot = await userFollowersRef.get();

    // Update each post on follower's timeline
    querySnapshot.forEach((doc) => {
        const followerId = doc.id;
        admin.firestore().collection('timeline').doc(followerId).collection('timelinePosts').doc(postId).get().then(doc => {
            if (doc.exists) {
                doc.ref.update(postUpdated);
            }
        });
    });
});


// When a post is deleted, delete post on timeline's of each follower (of post owner)
exports.onDeletePost = functions.firestore.document('/posts/{userId}/userPosts/{postId}').onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

    // Get all followers of post owner
    const userFollowersRef = admin.firestore.collection('followers').doc(userId).collection('userFollowers');
    const querySnapshot = await userFollowersRef.get();

    // delete each post on follower's timeline
    querySnapshot.forEach((doc) => {
        const followerId = doc.id;
        admin.firestore().collection('timeline').doc(followerId).collection('timelinePosts').doc(postId).get().then(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });
    });
});