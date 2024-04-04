exports.helloWorld = (req, res) => {
    let message = req.body.message || req.query.message || 'Hello World!';
    res.status(200).send(message);
};