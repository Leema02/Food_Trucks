const userSocketMap = {};

const addUserSocket = (userId, socket) => {
  console.log(userId)
  userSocketMap[userId] = socket;
  
};

const removeUserSocket = (socket) => {
  const userId = Object.keys(userSocketMap).find((key) => userSocketMap[key] === socket);
  if (userId) {
    delete userSocketMap[userId];
  }
};
const doesUserExist = (userId) => {
  return userSocketMap.hasOwnProperty(userId);
};
const getUserSocket = (userId) => userSocketMap[userId];
const sendToClient=(userId,event, data)=>{
  console.log(userId);
    if(doesUserExist(userId)){
      console.log(userId);
        getUserSocket(userId).emit(event,data)
    }
}
module.exports = {
    addUserSocket,
    removeUserSocket,
    getUserSocket,
    doesUserExist,
    sendToClient
  };