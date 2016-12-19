'''
Tensorflow operations that serve as the nodes in the computational graph

Nelson Chen 12/13/16 for Beer Recommendation Project
'''

####################################### Packages ###########################################

import tensorflow as tf

####################################### Functions ###########################################

def tf_repeat(tens,num):
    'Broadcast vectors to matrices for element wise multiplication'
    with tf.device("/cpu:0"):
        tens = tf.expand_dims(tens, 1) # convert column vector to N x 1 matrix
        tens_repeated = tf.tile(tens, [1, num]) #repeat vector to expand to N x num matrix

    return tens_repeated

def get_pred(feedback_u, item_num, user_num, dim, device):
    with tf.device(device):
        with tf.variable_scope("var", reuse=True):
            bias_global_var = tf.get_variable("bias_global", shape=[])
            w_bias_user = tf.get_variable("embd_bias_user", shape=[user_num])
            w_bias_item = tf.get_variable("embd_bias_item", shape=[item_num])

            w_user = tf.get_variable("embd_user", shape=[user_num, dim])
            w_item = tf.get_variable("embd_item", shape=[item_num, dim])
            w_feedback = tf.get_variable("feedback", shape=[item_num, dim])

            bias_i_mat = tf.transpose(tf_repeat(w_bias_item, user_num))
            bias_u_mat = tf_repeat(w_bias_user, item_num)
            feedback_vecs = tf.matmul(tf.matmul(feedback_u, w_feedback), tf.transpose(w_item))

            ratings = tf.matmul(w_user, tf.transpose(w_item))
            ratings = tf.add(ratings,tf.mul(tf.constant(1.0, shape=[user_num, item_num]), bias_global_var))
            ratings = tf.add(ratings, bias_i_mat)
            ratings = tf.add(ratings, bias_u_mat)
            ratings = tf.add(ratings, feedback_vecs)

        return ratings

def inference_svd(user_batch, item_batch, feedback_batch, user_num, item_num, dim=5, device="/cpu:0"):
    'Build inference part to the training algorithm'

    # CPU needed for this part
    with tf.device("/cpu:0"):
        with tf.variable_scope("var"):

            # Defining variables
            bias_global = tf.get_variable("bias_global", shape=[])
            w_bias_user = tf.get_variable("embd_bias_user", shape=[user_num])
            w_bias_item = tf.get_variable("embd_bias_item", shape=[item_num])
            w_user = tf.get_variable("embd_user", shape=[user_num, dim],
                                     initializer=tf.truncated_normal_initializer(stddev=0.02))
            w_item = tf.get_variable("embd_item", shape=[item_num, dim],
                                     initializer=tf.truncated_normal_initializer(stddev=0.02))
            w_feedback = tf.get_variable("feedback", shape=[item_num,dim],
                                           initializer = tf.truncated_normal_initializer(stddev=0.02))

            # Looking up the batch part of the variables
            bias_user = tf.nn.embedding_lookup(w_bias_user, user_batch, name="bias_user")
            bias_item = tf.nn.embedding_lookup(w_bias_item, item_batch, name="bias_item")

            embd_user = tf.nn.embedding_lookup(w_user, user_batch, name="embedding_user")
            embd_item = tf.nn.embedding_lookup(w_item, item_batch, name="embedding_item")

    with tf.device(device):
        # Compute the feedback parameter vectors
        feedback_vecs = tf.matmul(feedback_batch, w_feedback)

        # Compute the implicit factors and broadcast to matrix
        N_u = tf.pow(tf.reduce_sum(feedback_batch, 1), -0.5)
        N_u = tf_repeat(N_u, dim)

        # Calculate new user vec with implicit information
        embd_user = tf.add(embd_user,tf.mul(N_u,feedback_vecs))

        # Compute the inference value
        infer = tf.reduce_sum(tf.mul(embd_user, embd_item), 1)
        infer = tf.add(infer, bias_global)
        infer = tf.add(infer, bias_user)
        infer = tf.add(infer, bias_item, name="svd_inference")

        # Compute the regularization term
        regularizer = tf.add(tf.nn.l2_loss(embd_user), tf.nn.l2_loss(embd_item), name="svd_regularizer")
        regularizer = tf.add(regularizer, tf.reduce_sum(tf.matmul(feedback_batch, tf.mul(w_feedback, w_feedback))))
        regularizer = tf.add(regularizer, tf.nn.l2_loss(bias_user))
        regularizer = tf.add(regularizer, tf.nn.l2_loss(bias_item))
    return infer, regularizer


def optimiaztion(infer, regularizer, rate_batch, learning_rate=0.001, reg=0.1, device="/cpu:0"):
    'Optimization function to calculate cost and specify optimization parameters'

    with tf.device(device):

        # Calculate the squared error
        cost_l2 = tf.nn.l2_loss(tf.sub(infer, rate_batch))

        # Calculate the cost of regularization term and final cost
        penalty = tf.constant(reg, dtype=tf.float32, shape=[], name="l2")
        cost = tf.add(cost_l2, tf.mul(regularizer, penalty))

        # Choose optimization algorithm for training
        #train_op = tf.train.AdamOptimizer(learning_rate).minimize(cost)
        train_op = tf.train.RMSPropOptimizer(learning_rate).minimize(cost)
    return cost, train_op
