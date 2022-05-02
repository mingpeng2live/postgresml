-- Exit on error (psql)
\set ON_ERROR_STOP true

SELECT pgml.load_dataset('iris');

-- view the dataset
SELECT* FROM pgml.iris LIMIT 10;

-- train a simple model to classify the data
SELECT * FROM pgml.train('Iris Classifier', 'classification', 'pgml.iris', 'target');

-- check out the predictions
SELECT target, pgml.predict('Iris Classifier', ARRAY[sepal_length, sepal_width, petal_length, petal_width]) AS prediction
FROM pgml.iris 
LIMIT 10;

-- After a project has been trained, ommited parameters will be reused from previous training runs
-- In these examples we'll reuse the training data snapshots from the initial call.
-- linear models
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'ridge');
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'stochastic_gradient_descent');
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'perceptron');
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'passive_aggressive');
-- support vector machines
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'svm');
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'nu_svm');
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'linear_svm');
-- ensembles
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'ada_boost');
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'bagging');
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'extra_trees', hyperparams => '{"n_estimators": 10}');
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'gradient_boosting_trees', hyperparams => '{"n_estimators": 10}');
-- Histogram Gradient Boosting is too expensive for normal tests on even a toy dataset
-- SELECT * FROM pgml.train('Iris Classifier', 'hist_gradient_boosting', '{"max_iter": 2}');
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'random_forest', hyperparams => '{"n_estimators": 10}');
-- other
-- Gaussian Process is too expensive for normal tests on even a toy dataset
-- SELECT * FROM pgml.train('Iris Classifier', 'classification', 'pgml.iris', 'target', 'gaussian_process', '{"max_iter_predict": 100, "warm_start": true}');
SELECT * FROM pgml.train('Iris Classifier', algorithm => 'xgboost');


-- check out all that hard work
SELECT trained_models.* FROM pgml.trained_models 
JOIN pgml.models on models.id = trained_models.id
ORDER BY models.metrics->>'f1' DESC LIMIT 5;

-- deploy the random_forest model for prediction use
SELECT * FROM pgml.deploy('Iris Classifier', 'most_recent', 'random_forest');
-- check out that throughput
SELECT * FROM pgml.deployed_models ORDER BY deployed_at DESC LIMIT 5;

-- do some hyper param tuning
-- TODO SELECT pgml.hypertune(100, 'Iris Classifier', 'classification', 'pgml.iris', 'target', 'gradient_boosted_trees');

-- deploy the "best" model for prediction use
SELECT * FROM pgml.deploy('Iris Classifier', 'best_score');
SELECT * FROM pgml.deploy('Iris Classifier', 'most_recent');
SELECT * FROM pgml.deploy('Iris Classifier', 'rollback');
SELECT * FROM pgml.deploy('Iris Classifier', 'best_score', 'svm');

-- check out the improved predictions
SELECT target, pgml.predict('Iris Classifier', ARRAY[sepal_length, sepal_width, petal_length, petal_width]) AS prediction
FROM pgml.iris 
LIMIT 10;