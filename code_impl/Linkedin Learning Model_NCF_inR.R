################################################################################
#Linkedin Learning Recommender System using Neural CF

  #https://engineering.linkedin.com/blog/2020/course-recommendations-ai-part-two
  #Original model structure consists of two parts...
    #this code only implements the first part, which is ncf
    
  #Before using this code, you need...
    #X_train
      #1) pre-defined course-to-course similarity
      #2) boolean which shows interaction/no interaction.
    #y_label

    #!!Be careful for data leakage!#







################################################################################








#Set Model Structure============================================================
n_dim = length(all_courses)

#1) Set Inputs------------------------------------------------------------------
linkedin_input_userhistory = 
  layer_input(shape = 1 , name = "linkedin_input_userhistory")

linkedin_input_coursesim = 
  layer_input(shape = n_dim , name = "linkedin_input_coursesim")


#2) Set Hyperparameters---------------------------------------------------------
sigma = 0.01
lambda = 0.00
embedding_dim = 24


#3) Hidden Layers for each input------------------------------------------------

#user history
#Concatenate and learn through hidden layers
linkedin_mlp_user <- 
  layer_flatten(linkedin_input_userhistory) %>%
  #Hidden Layer 1
  layer_batch_normalization() %>%
  layer_dense(units = 2 * n_dim, 
              kernel_regularizer = regularizer_l2(lambda),
              name = "linkedin_user_mlp_layer1") %>%
  layer_activation_leaky_relu() %>% 
  layer_dropout(rate = 0.33) %>% 
  #Hidden Layer 2
  layer_batch_normalization() %>%
  layer_dense(units = 1 * n_dim, 
              kernel_regularizer = regularizer_l2(lambda),
              name = "linkedin_user_mlp_layer2") %>% 
  layer_activation_leaky_relu() %>% 
  layer_dropout(rate = 0.33) %>% 
  #Hidden Layer 3
  layer_batch_normalization() %>%
  layer_dense(units = 0.5 * n_dim, 
              kernel_regularizer = regularizer_l2(lambda),
              name = "linkedin_user_mlp_layer3")  %>%    
  layer_activation_leaky_relu() %>% 
  layer_dropout(rate = 0.33)


#course similarity
linkedin_mlp_course <- 
  layer_flatten(linkedin_input_coursesim) %>%
  #Hidden Layer 1
  layer_batch_normalization() %>%
  layer_dense(units = 2 * n_dim, 
              kernel_regularizer = regularizer_l2(lambda),
              name = "linkedin_course_mlp_layer1") %>%
  layer_activation_leaky_relu() %>% 
  layer_dropout(rate = 0.33) %>% 
  #Hidden Layer 2
  layer_batch_normalization() %>%
  layer_dense(units = 1 * embedding_dim, 
              kernel_regularizer = regularizer_l2(lambda),
              name = "linkedin_course_mlp_layer2") %>% 
  layer_activation_leaky_relu() %>% 
  layer_dropout(rate = 0.33) %>% 
  #Hidden Layer 3
  layer_batch_normalization() %>%
  layer_dense(units = 0.5 * n_dim, 
              kernel_regularizer = regularizer_l2(lambda),
              name = "linkedin_course_mlp_layer3")  %>%    
  layer_activation_leaky_relu() %>% 
  layer_dropout(rate = 0.33)



#4) Embedding Layer-------------------------------------------------------------


linkedin_user_embedding <-
  linkedin_mlp_user %>% layer_flatten(name = "linkedin_user_embedding")


linkedin_course_embedding <-
  linkedin_mlp_course %>% layer_flatten(name = "linkedin_course_embedding")




#5) Dot product and predict

linkedin_dot_embedding = 
  layer_dot(inputs = list(linkedin_user_embedding, linkedin_course_embedding),
            axes = 1,
            name = "linkedin_dot")

linkedin_label <- 
  linkedin_dot_embedding %>% 
  layer_dense(units = 1, 
              activation = "sigmoid", 
              kernel_initializer = "lecun_uniform",
              name = "linkedin_prediction")    











# For non-sequential models, need to specify inputs and outputs: 
linkedin_model <- 
  keras_model(list(linkedin_input_userhistory , linkedin_input_coursesim), 
              linkedin_label)

# Compile model ------------------------------------------------------------------------

linkedin_model %>% compile(
  optimizer = optimizer_adam(lr = 0.001),
  loss = "binary_crossentropy", 
  metrics = c("accuracy")
)

summary(linkedin_model)



#########################################################################################










#train the model
linkedin_history <- linkedin_model %>% fit(
  
  x = list(
    x_input[ , "interaction"], #1st column is interaction
    x_input[ , -1] #columns except the first column is similarities btw courses.
  ),
  
  y = y_label,
  
  
  verbose = 1,
  epochs = 50,
  batch_size = 16, 
  validation_split = 0.3,
  callbacks = list(callback_early_stopping(patience = 3),
                   callback_tensorboard("logs/run_a"))
  
)

end.time = Sys.time() - start.time
print(end.time)



best_epoch <- which(history$metrics$val_loss == min(history$metrics$val_loss))
loss <- history$metrics$val_loss[best_epoch] %>% round(3)
acc <- history$metrics$val_accuracy[best_epoch] %>% round(3)

glue("The best epoch is {best_epoch}th and had a loss of {loss} and accuracy of {acc}")
##########################################################################################



