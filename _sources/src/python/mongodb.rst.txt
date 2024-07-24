NoSQL databases with MongoDB
============================

.. |cover_picture| image:: /src/python/images/mongodb.png
   :width: 430px

|cover_picture|

MongoDB is an open source NoSQL database management program. NoSQL (Not only SQL) is used as an alternative to traditional relational databases. NoSQL databases are quite useful for working with large sets of distributed data. MongoDB is a tool that can manage document-oriented information, store or retrieve information.

Install MongoDB
---------------

MongoDB can be installed using docker.

1) Pull the MongoDB Docker Image

.. code::

   docker pull mongodb/mongodb-enterprise-server:latest

2) Run the Image as a container

.. code::

   docker run --name mongodb -p 27017:27017 -d mongodb/mongodb-enterprise-server:latest


Basic MongoDB commands
----------------------

Create a collection

.. code::

   db.createCollection('studentmarks')

Get information about a collection

.. code::

   db.getCollection("studentmarks").find({})

Insert a new line inside a collection

.. code::

   db.studentmarks.insertOne({first_name:"charles-auguste", last_name: 'GOURIO', mark: 12.5})

   db.studentmarks.insertMany([
     {first_name:"Victor", last_name: 'MARCELLIN', mark: 14.75},
     {first_name:"Mehdi", last_name: 'KHAMMASSI', mark: 6},
     {first_name:"Asma", last_name: 'MAIRECH', mark: 17.25},
     {first_name:"Adrien", last_name: 'LECLER', mark: 9},
     {first_name:"YuYu", last_name: 'PAI', mark: 13}
   ])

Filter data (with and without Regex)

.. code::

   db.studentmarks.find({first_name:"Victor"})

   db.studentmarks.find({first_name: /^A.*/})

   db.studentmarks.find({mark : {$in: [12.5,14.75]}})


.. note::

   **Numeric operations**

   ======   =======     ========================
   symbol   meaning     example
   ======   =======     ========================      
   $eq      =           {mark: {$eq: 20}}
   $lt      <           {mark: {$lt: 20}}
   $gt      >           {mark: {$gt: 20}}
   $gte     >=	         {mark: {$gte: 22}}
   $lte     <=          {mark: {$lte: 22}}
   $ne      !=          {mark: {$ne: 22}}
   $en      isin()      {mark: {$dans: [20,22]}}
   $nin     notin()     {mark: {$nin: [22,25]}}
   ======   =======     ========================

Complex queries

.. code::

   db.studentmarks.find({$or: [{mark : {$gte: 10}}, {last_name:"KHAMMASSI"}]})

.. note::

   **And, Or and Not**

   ======   =====================
   symbol   example
   ======   =====================
   $and 	{$and : [{mark: {$eq: 20}}, {last_name:"MARCELLIN"}]}
   $or 	    {$or : [{mark: {$eq: 20}}, {last_name:"MARCELLIN"}]}
   $not     _
   ======   =====================


GUI Interface for Mongo
-----------------------

Studio 3T is a free 3rd party GUI/IDE software for MongoDB

It can be downloaded `here <https://studio3t.com/>`_

.. |studio3T_picture| image:: /src/python/images/studio3T.png
   :width: 800px

|studio3T_picture|


Python and PyMongo
------------------

Documentation about pyMongo can be found here :
`https://pymongo.readthedocs.io/en/stable/tutorial.html <https://pymongo.readthedocs.io/en/stable/tutorial.html>`_

**Small cheat sheet**

Making a connection with client

.. code::

   # Import package
   from pymongo import MongoClient

   # Connection with URI
   client = MongoClient("mongodb://localhost:27017/")

Getting a database and access a collection

.. code::

   db = client.test_database
   collection = db.test_collection

In pyMongo, document are stored as python `Dictionnary`. Here is a small comparative
table of MonoDB functions X python functions

=============           ====================
MongoDB                 Python
=============           ====================
insertOne({})           insert_one({})
_                       find_one({})
_                       find({})
_                       count_documents({})
=============           ====================
                        
   



