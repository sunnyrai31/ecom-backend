export const enforceJsonType = (req, res, next) => {
               const contentType = req.headers['content-type'];
             
               const skipCheck = ['GET', 'DELETE', 'OPTIONS'].includes(req.method);
             
               if (!skipCheck && contentType !== 'application/json') {
                 return res.status(415).json({ error: 'Only application/json supported' });
               }
             
               next();
             };
             