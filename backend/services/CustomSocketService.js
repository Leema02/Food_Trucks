const EventBooking = require("../models/eventBookingModel");

const userSocketMap = {};
const adminSocketMap = {};

const addUserSocket = (userId, socket) => {
  console.log(userId)
  if(userId.role=='admin')
  {
    adminSocketMap[userId.id] = socket;
  }
  else{
  userSocketMap[userId.id] = socket;

  }
  
};

const removeUserSocket = (socket) => {
  const userId = Object.keys(userSocketMap).find((key) => userSocketMap[key] === socket);
  if (userId) {
    delete userSocketMap[userId];
    return;
  }
    const adminId = Object.keys(adminSocketMap).find((key) => adminSocketMap[key] === socket);
    delete adminSocketMap[adminId];

};
const doesUserExist = (userId) => {
  return userSocketMap.hasOwnProperty(userId);
};
const doesAdminExist = (userId) => {
  return adminSocketMap.hasOwnProperty(userId);
};
const getUserSocket = (userId) => userSocketMap[userId];
const sendToClient=(userId,event, data)=>{
  console.log(userId);
  console.log(doesUserExist(userId));
    if(doesUserExist(userId)){
      console.log(userId);
        getUserSocket(userId).emit(event,data)
    }
    else if(doesAdminExist(userId)){
      adminSocketMap[userId].emit(event,data);
    }
}
function notifyAdmins(report){
  for(let i in adminSocketMap){
    sendToClient(i,"Notification",report);
  }
}
function translateTime(hour24) {
  if (hour24 === 0) {
    return { hour12: 12, meridiem: 'ص' };      
  } else if (hour24 < 12) {
    return { hour12: hour24, meridiem: 'ص' };   
  } else if (hour24 === 12) {
    return { hour12: 12, meridiem: 'م' };       
  } else {
    return { hour12: hour24 - 12, meridiem: 'م' };
  }
}
async function getEventsStartingIn24Hours() {
  const today = new Date();
  const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000);
  const year  = tomorrow.getFullYear();
  const month = tomorrow.getMonth();
  const day   = tomorrow.getDate();
  const hour  = tomorrow.getHours();
  const startOfTargetDay = new Date(year, month, day, 0, 0, 0, 0);
  const startOfNextDay   = new Date(year, month, day + 1, 0, 0, 0, 0);
  const { hour12, meridiem } = translateTime(hour);
  const hourString = hour12.toString();
  const events = await EventBooking.find({
    event_start_date: {
      $gte: startOfTargetDay,
      $lt:  startOfNextDay
    },
    start_time: {
      $regex: `^${hourString}:\\d{2}\\s?${meridiem}$`
    }
  }).populate('truck_id').exec();

  return events;
}
module.exports = {
    addUserSocket,
    removeUserSocket,
    getUserSocket,
    doesUserExist,
    sendToClient,
    getEventsStartingIn24Hours,
    notifyAdmins
  };