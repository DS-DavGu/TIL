#########################################################################################
#Neural Matrix Factorization in R




  #implementation of... 

    #Neural Collaborative Filtering, Xiangnan He and Lizi Liao and Hanwang Zhang 
      #and Liqiang Nie and Xia Hu and Tat-Seng Chua,
      #2017, 1708.05031, arXiv
      #https://arxiv.org/pdf/1708.05031.pdf

    #From the paper, this code in particular is an attempt to implement...
      #the combination between GMF & MLP Structure.





  #Parts that require personal inputs...
    #dataframe "data"
      #from the data, you need to construct...
        #X_train, which is user & item dense ids
        #Y_train, which is the label {0,1}

#########################################################################################
#========================================================================================
start.time = Sys.time()
set.seed(0304)




#임베딩 차원 및 필수 하이퍼퍼라미터 지정-------------------------------------------------


  
  ##Embedding Dimension
  embedding_dim <- 24
  
  ##Model
  #input layers
  input_users   <- layer_input(shape = 1, name = "users")
  input_items <- layer_input(shape = 1, name = "items")
  
  
  sigma = 0.01
  lambda = 0.00
  
  
  
  
  
  
  n_users = n_distinct(data$user.id)
  n_items = n_distinct(data$item.id)
  




#Neural MF 구조 DEFINE-------------------------------------------------------------------
#https://media.vlpt.us/images/jinseock95/post/e36a364e-415d-4320-8927-bd9d761538b4/NCF.png


#좌측에서는 Matrix Factorization을, 우측에서는 Multi-layered perceptron을 실행함
#Basic NCF Structure와 다른 점은 
  #Matrix Fact.용 임베딩 차원과 MLP용 임베딩 차원이 따로 생성된다는 점.
  #따라서 차원도 다르게 지정할 수 있다고 함...

  
  #1) Generalized Matrix Factorization---------------------------------------------------
  gmf_user_embedding <-
    input_users %>% 
    layer_embedding(input_dim = n_users,
                    output_dim = embedding_dim,
                    embeddings_initializer = initializer_random_normal(0, sigma),
                    embeddings_regularizer = regularizer_l2(lambda),
                    input_length = 1,
                    name = "gmf_user_embedding")
  gmf_user_latent <- gmf_user_embedding %>% layer_flatten(name = "gmf_user_latent")
  
  gmf_item_embedding <-
    input_items %>% 
    layer_embedding(input_dim = n_items,
                    output_dim = embedding_dim,
                    embeddings_initializer = initializer_random_normal(0, sigma),
                    embeddings_regularizer = regularizer_l2(lambda),
                    input_length = 1,
                    name = "gmf_item_embedding")
  gmf_item_latent <- gmf_item_embedding %>% layer_flatten(name = "gmf_item_latent")
  
  gmf_branch <- layer_multiply(list(gmf_user_latent, gmf_item_latent))

  
  
  #2) Multi-layer Perceptron-------------------------------------------------------------
  mlp_user_embedding <-
    input_users %>% 
    layer_embedding(input_dim = n_users,
                    output_dim = embedding_dim,
                    embeddings_initializer = initializer_random_normal(0, sigma),
                    embeddings_regularizer = regularizer_l2(lambda),
                    input_length = 1,
                    name = "mlp_user_embedding")
  mlp_user_latent <- mlp_user_embedding %>% layer_flatten(name = "mlp_user_latent")
  
  mlp_item_embedding <-
    input_items %>% 
    layer_embedding(input_dim = n_items,
                    output_dim = embedding_dim,
                    embeddings_initializer = initializer_random_normal(0, sigma),
                    embeddings_regularizer = regularizer_l2(lambda),
                    input_length = 1,
                    name = "mlp_item_embedding")
  mlp_item_latent <- mlp_item_embedding %>% layer_flatten(name = "mlp_item_latent")
  
  
  
  
  #Biases
  user_bias_mlp <- input_users %>%
    layer_embedding(
      input_dim = n_users,
      output_dim = 1,
      name = "user_bias_mlp"
    ) %>% 
    layer_flatten()
  
  item_bias_mlp <- input_items %>%
    layer_embedding(
      input_dim = n_items,
      output_dim = 1,
      name = "item_bias_mlp"
    ) %>% 
    layer_flatten()
  
  
  
  
  
  #Concatenate and learn through hidden layers
  mlp_branch <- 
    layer_concatenate(list(mlp_user_latent, mlp_item_latent, user_bias_mlp, item_bias_mlp)) %>%
    #Hidden Layer 1
    layer_batch_normalization() %>%
    layer_dense(units = 3 * embedding_dim, 
                kernel_regularizer = regularizer_l2(lambda),
                name = "mlp_layer1") %>%
    layer_activation_leaky_relu() %>% 
    layer_dropout(rate = 0.33) %>% 
    #Hidden Layer 2
    layer_batch_normalization() %>%
    layer_dense(units = 2 * embedding_dim, 
                kernel_regularizer = regularizer_l2(lambda),
                name = "mlp_layer2") %>% 
    layer_activation_leaky_relu() %>% 
    layer_dropout(rate = 0.33) %>% 
    #Hidden Layer 3
    layer_batch_normalization() %>%
    layer_dense(units = 1 * embedding_dim, 
                kernel_regularizer = regularizer_l2(lambda),
                name = "mlp_layer3")  %>%    
    layer_activation_leaky_relu() %>% 
    layer_dropout(rate = 0.33)


  

#Final Prediction======================================================================
label <- 
  layer_concatenate(list(mlp_branch, gmf_branch)) %>% 
  layer_dense(units = 1, 
              activation = "sigmoid", 
              kernel_initializer = "lecun_uniform",
              name = "prediction")    

# For non-sequential models, need to specify inputs and outputs: 
model <- keras_model(list(input_users , input_items), label)









# Compile model ------------------------------------------------------------------------

model %>% compile(
  optimizer = optimizer_adam(lr = 0.001),
  loss = "binary_crossentropy", 
  metrics = c("accuracy")
)

summary(model)






#########################################################################################
#########################################################################################
#########################################################################################


#train the model
history <- model %>% fit(
  
  x = list(
    x_train[, "user", drop = FALSE],
    x_train[, "item", drop = FALSE]
  ),
  
  y = y_train,
  
  
  verbose = 1,
  epochs = 200,
  batch_size = 128, 
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











