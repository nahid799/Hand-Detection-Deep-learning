@Author: Md Nahid Hossain (mdnhossain@cs.stonybrook.edu) & Syed Masum Billah (sbillah@cs.stonybrook.edu)
@Date: 12-15-2014
@Version 1.0.



All codes provided here in the two folders are written by us. The function calls that is not written in any file in any of the folders are done using the library functions.

The link of the complete project:

https://drive.google.com/file/d/0B28OtkmG37E6WkdhVDZWSWVCVDg/view?usp=sharing


Train:
==========================================================================
For the train data the positive and negative image patches are need to be kept in separate folder. 
    For extracting the positive and negative patches run the create_train_hand_dataset.m file and neg_patch.m file respectively in the Train folder. 
    Now run the Train.m file to train the data. It will generate a model variable which will be used in the detection phase. 


Detection:
==========================================================================
Parameters:
==========================================================================
    num_rotation = 8 (45 degree rotation)
    num_samples  = num_boxes = 100 
    num_voting = 2
    encoder = deepeval feature extractor.
    svm_model = located in svm_models/* directory


Directory structure:
===========================================================================
All data are located in ../data directory. Here is the purpose and format of other directories under data:
../data/
    proposals: containes "proposals" variables for image_name.jpg. The .mat file has 3 cells: {proposal_boxes, is_ground_truth?, ground_truth_orientation}
    predictions: contains the "prediction" variables of format {CNN features, svm_confidence, our_labels} for each image. 
    post_prediction: contains "post_prediciton" varialbes of format: {finalt_confidence, ground_truth} for each proposals of an image 
    post_prediction2: debug purpose
    results: output images with bounding boxes are there.

How to run:
===================================================================================
1. First run startup.m for warming up the deep_eval and mkl library.

2. You need to extract all the proposal first. So, run extractProposal.m. 
    It read all the images from directory ../data/test_data/image/* and extract their proposal.
    After extraction proposals for each of the images are saved in ../data/proposals/* directory after 
    their name plus .mat extension.

2.a. Number of proposals varies from image to image. In order to cut processing time, we consider top 100 
    proposals for each image. In our experiments, it is found that we are not missing any hand ground truth by
    taking only 100 proposals.

3. Now, look at workflow.m file. It outlines handDetection procedure by calling in the following orders:
    runHandDetector(file_name, encoder);
    analyzeHandDetector(file_name,num_boxes,num_rotation,num_voting);
    showProposal(file_name,100,8,2);
    ap = detection_ap();
    
4. For each image, we have 100 proposals, each of which is rotated by 45 degree (8 times). So, total features are 
   num_sample*num_rotation.    

5. To generate the result images run the showAll.m file. The data needs to be kept in the ../data/images/ folder. The proposals and predictions are also needed to be generated for these particular files.

6. To run a single image you can run the demo.m file. It'll take the model generated during the training phase and detect hand using it on that one particular image.
