const ProblemReport = require('../models/problemReportModel');
const { notifyAdmins, sendToClient } = require("../services/CustomSocketService");

exports.createReport = async (req, res) => {
  const { category, subject, description } = req.body;
  const { _id, role_id } = req.user;

  try {
    const report = await ProblemReport.create({
      user_id: _id,
      role: role_id,
      category,
      subject,
      description,
    });
 const io = req.app.get("io"); 
    // io.emit("new_report", {
    //   _id: report._id,
    //   category,
    //   subject,
    //   description,
    //   role: role_id,
    //   submittedAt: report.createdAt,
    // });
    notifyAdmins(report);

    res.status(201).json(report);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


exports.getAllReports = async (req, res) => {
  try {
    const reports = await ProblemReport.find()
      .populate('user_id', 'F_name L_name email_address role_id');
    res.json(reports);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateReport = async (req, res) => {
  const { id } = req.params;
  const { status, admin_response } = req.body;

  try {
    const updated = await ProblemReport.findByIdAndUpdate(
      id,
      { status, admin_response },
      { new: true }
    );
    sendToClient(updated.user_id.toString(),"Notification",{title :`Report update`,message:`${status}`});
    res.json(updated);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
