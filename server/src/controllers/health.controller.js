const getHealth = (req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'nexa-backend',
  });
};

module.exports = {
  getHealth,
};
