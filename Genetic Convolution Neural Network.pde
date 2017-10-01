
int imageWidth = 128;
int imageHeight = 128;
int changeCount = 0;
int saveValue = 5000;
double transformationAdaptionFactor = 1;
int count = 0;
double beforeChange= 0;
int saveCount = 0;
int changerConvol;
int changerNeuron;
int previousReturnedPercentage = 0;
double [] guessNumber = new double[10];
double [] rightAnswer = new double[10];
int stride = 5;
float returnedPercentage=0;
int scaleDown = 2;
int numberChoosen;
float[][] pixels = new float[imageWidth][imageHeight];
boolean update = true;
float[][] transformationBackup = new float[9][9];
float[][][][] transformation = new float[6][50][stride][stride];
double UPDOWNCheck = 0;
PImage img;
String loadImageNumber;
int returnValue = 0;
PImage returnImage;

int largestConvolution = 0;
float[][][] neuronWeights = new float[6][5000][50];
float[] weightBackup = new float[50];

int size = 4;//Integer.parseInt(setupImport[0]);
int[] neurons = new int[size];

float correctGuesses = 0;
float totalGuesses = 0;

void setup()
{
  size(1000, 600);
  imageMode(CENTER);
  background(255);
  returnImage = createImage(128,128,RGB);
  String setupImport[] = loadStrings("setup.txt");

  for (int i = 1; i < setupImport.length; i++)
  {
    neurons[i-1] = Integer.parseInt(setupImport[i]);
  }
  for (int i = 0; i < neurons.length; i++)
  {
    if (neurons[i] > largestConvolution)
    {
      largestConvolution = neurons[i];
    }
  }

  for (int b = 0; b < neurons.length; b++)
  {
    int move = 1;
    count=0;
    String transformationImport[] = loadStrings("Convolution" + (b +1)+ ".txt");
    String neuronWeightsImport[] = loadStrings("weight" + (b+2) + ".txt");

    for (int i = 0; i < neurons[b]; i++)
    {
      for (int j = 0; j < stride; j++)
      {
        for (int o = 0; o < stride; o++)
        {
          transformation[b][i][j][o] = (int)Double.parseDouble(transformationImport[move]);
          move++;
        }
      }
    } 
    if (b == neurons.length-1)
    {
      for (int i = 0; i < neurons[b] * 10; i++)
      {
        for (int j = 0; j < neurons[b]; j++)
        {
          neuronWeights[b][i][j] = Float.parseFloat(neuronWeightsImport[count]);
          count++;
        }
      }
    } else
    {
      for (int i = 0; i < neurons[b] * neurons[b + 1]; i++)
      {
        for (int j = 0; j < neurons[b]; j++)
        {
          neuronWeights[b][i][j] =  Float.parseFloat(neuronWeightsImport[count]);
          count++;
        }
      }
    }
  }
}

void draw()
{
  background(0);
  float dotRadius;
  fill(255);
  //Setting distance that neurons are kept apart
  int widthOfNeurons = ((width-20)/neurons.length);
  float heightOfNeurons = ((height-20)/largestConvolution);
  
  //Random number used to choose image in file
  int r = (int)(Math.random()*4000);
  totalGuesses++;
  //
  numberChoosen = (int) (Math.random() * 9);
  if (r < 10)
  {
    loadImageNumber = "0000" + r;
  } else if (r < 100)
  {
    loadImageNumber = "000" + r;
  } else if (r < 1000)
  {
    loadImageNumber = "00" + r;
  } else if (r < 10000)
  {
    loadImageNumber = "0" + r;
  } else
  {
    loadImageNumber = "" + r;
  }
  textSize(12);
  //Draw image that is currently being used
  img = loadImage("NIST\\"+numberChoosen + "\\hsf_0_" + loadImageNumber + ".png");
  text("Given number:", width - img.width-img.width/2, img.height - (img.height/2) - 10); // Draw text above photo
  image(img, width - img.width, img.height); // Draw image
  text("Guessed number:", width - img.width - img.width/2, (height - img.height) - (img.height/2) - img.height/2- 10);

  //Draw thick and thin line colours for reference
  text("Thick line: ", 6, height -25);
  fill(100, 150, 255);
  stroke(100, 150, 255);
  rect(80, height-35, 10, 10);
  fill(255);
  text("Thin line: ", 12, height-10);
  stroke(100, 150, 0);
  fill(100, 150, 0);
  rect(80, height-20, 10, 10);
  fill(255);

  //Draw Network
  for (int i = 0; i < neurons.length; i++)
  {
    float[] varience = new float[neurons[i]]; // Setting how large circle will be by how large of a change is added
    for (int a = 0; a < neurons[i]; a++)
    {
      for (int e = 0; e < stride; e++)
      {
        for (int z = 0; z < stride; z++)
        {
          varience[a]+= Math.abs((float)transformation[i][a][e][z]); // Adding how large of change is found
        }
      }

      dotRadius = (float)( ((width + height)/2) /varience[a] ); // Setting radius of circle
      float startAt; // Finding the midpoint of line 
      startAt = (float)(height/2) - ((neurons[i]*heightOfNeurons)/2);
      if (i==changerConvol&&changerNeuron==a)
      {
        fill(255, 10, 253);
        stroke(255, 10, 253);
      } else
      {
        fill(200, 100, 100);
        stroke(200, 100, 100);
      }
      ellipse((i*widthOfNeurons) + 10, ((a*heightOfNeurons)) + startAt, dotRadius, dotRadius);
      if (i != neurons.length-1 )
      {
        for (int k = 0; k < neurons[i+1]; k++)
        {
          float nextStartAt = (float)(height/2) - ((neurons[i + 1]*heightOfNeurons)/2);
          strokeWeight((float)(2 *(neuronWeights[i][k][a] /200)));
          if (i==changerConvol&&changerNeuron==a)
          {
            fill(255, 10, 253);
            stroke(255, 10, 253);
          } else
          {
            fill(100, 150, (255*(neuronWeights[i][k][a])/100));
            stroke(100, 150, (255*(neuronWeights[i][k][a])/100));
          }
          line((i*widthOfNeurons) + 10, (a*heightOfNeurons)+startAt, ((i+1)*widthOfNeurons)+10, ((k)*heightOfNeurons)+nextStartAt );
        }
      }
    }
  }

  neuralNetwork();
  fill(255);
  rect((float)(width - img.width-img.width/2), (float)((height - img.height) - (img.height/2) - img.height/2), img.width, img.height);
  int sizeOfText = 100;
  textSize(sizeOfText);
  fill(0);
  if (returnValue == numberChoosen)
  {
    fill(0, 100, 0);
  } else
  {
    fill(255, 0, 0);
  }
  text(returnValue, width - img.width/2 - sizeOfText, height - img.height/2 - sizeOfText);
 // image(returnImage,100,100);
}
void neuralNetwork ()
{
  for (int i = 0; i < imageWidth; i++)
  {
    for (int j = 0; j < imageHeight; j++)
    {
      color mycolor = img.get(i, j);
      float red = red(mycolor);
      float green = green(mycolor);
      float blue = blue(mycolor);
      int grey = (int)(red+green+blue)/3;
      pixels[i][j] = 255-grey;
    }
  }

  returnValue = Convolution();

  if (returnValue == numberChoosen)
  {
    rightAnswer[returnValue]++;
    correctGuesses++;
  }
  guessNumber[numberChoosen]++;
  returnedPercentage = ((float) correctGuesses / (float) totalGuesses) * 100;
  if (returnedPercentage > UPDOWNCheck)
  {
    println("                                                                                                  %" + ((returnedPercentage) + " | UP " + (returnedPercentage - beforeChange)) + "       " + numberChoosen+ "  " + loadImageNumber);
  } else
  {
    println("%" + (returnedPercentage) + " | DOWN "+ ( returnedPercentage - beforeChange) + "       " + numberChoosen + "  " + loadImageNumber);
  }
  UPDOWNCheck = returnedPercentage;
  changeCount++;
  saveCount++;
  int timesRunThrough;
  timesRunThrough = (int)Math.pow(returnedPercentage, transformationAdaptionFactor);


  if (timesRunThrough < 10)
  {
    timesRunThrough =10;
  }
  if (changeCount > timesRunThrough)
  {
    update = true;
    if (returnedPercentage < beforeChange)
    {

      for (int i = 0; i < stride; i++)
      {
        for (int j = 0; j < stride; j++)
        {
          transformation[changerConvol][changerNeuron][i][j] = transformationBackup[i][j];
        }
      }
      for (int i = 0; i < neurons[changerConvol+1]; i++)
      {
        neuronWeights[changerConvol][changerNeuron][i] = weightBackup[i];
      }
      println("UPDATE DELETED ");
    } else
    {
      println("UPDATED");
    }
    //println("SAVED");
    saveCount = 0;
    //println("GUESSED        ||     GIVEN" );
    //for (int i = 0; i < 10; i++)
    //{
    //  println("Number "+ i + ": " + rightAnswer[i] + "  |  " + "Number "+ i + ": " + guessNumber[i] );
   // }
   // for (int i = 0; i < 10; i++)
   // {
    //  rightAnswer[i]=0;
    //  guessNumber[i]=0;
   // }
    //if (returnedPercentage >90 )
    //{

    //  println("You did it!");
      //break;
    //}


    changerConvol = (int) (Math.random() * neurons.length - 1);
    changerNeuron = (int) (Math.random() * (neurons[changerConvol]));
    println("CONVOL CHANGE: " + changerConvol + " NEURON CHANGE: " + changerNeuron);

    for (int i = 0; i < stride; i++)
    {
      for (int j = 0; j < stride; j++)
      {
        transformationBackup[i][j] = transformation[changerConvol][changerNeuron][i][j];
      }
    }
    for (int i = 0; i < neurons[changerConvol+1]; i++)
    {
      weightBackup[i] =  neuronWeights[changerConvol][changerNeuron][i];
    }

    int[] weight = {10, 5, 0, -5, -10};
    int chooser;

    for (int b = 0; b < stride; b++)
    {
      for (int i = 0; i < stride; i++)
      {
        chooser = (int) (Math.random() * 5);
        transformation[changerConvol][changerNeuron][b][i] = weight[chooser];
      }
    }
    for (int j = 0; j < neurons[changerConvol+1]; j++)
    {
      neuronWeights[changerConvol][changerNeuron][j] = (int)(Math.random()*100);
    }
    beforeChange = returnedPercentage;
    changeCount = 0;
  }
}

int Convolution()
{
  int sizeDownHeight = imageHeight;
  int sizeDownWidth = imageWidth;
  float[] valueOutput = new float[11];
  float largestOutput;
  int outputNumber = 0;
  float[][][][] convolutions = new float[neurons.length][largestConvolution][width][height];
  float[][][][] scaleDownARRAY = new float[neurons.length][largestConvolution][width][height];
  float difference = 0;
  for (int b = 0; b < neurons.length; b++)
  {
    if (b != 0)
    {
      for (int m = 0; m < neurons[b]; m++)
      {
        for (int i = 0; i < neurons[b - 1]; i++)
        {
          for (int j = 0; j < (sizeDownWidth); j++)
          {
            for (int k = 0; k < (sizeDownHeight); k++)
            {
              convolutions[b][m][j][k] = (float)(((convolutions[b - 1][i][j][k]))*(neuronWeights[b][i][m])) / (float)(Math.pow(sizeDownWidth, 2));
            }
          }
        }
      }
      for (int o = 0; o < neurons[b]; o++)
      {
        for (int p = 0; p < (sizeDownWidth - (stride)); p++)
        {
          for (int j = 0; j < (sizeDownHeight - (stride)); j++)
          {
            for (int i = 0; i < stride; i++)
            {
              for (int k = 0; k < stride; k++)
              {
                difference += ( (convolutions[b][o][p + i][j + k] * transformation[b][o][i][k]));
              }
            }


            convolutions[b][o][p][j] = difference /(int)(Math.pow(stride, 2));


            difference = 0;
          }
        }
      }
      float largest;
      float sizeInput;
      for (int o = 0; o < neurons[b]; o++)
      {
        for (int p = scaleDown; p < (sizeDownHeight - (scaleDown)); p++)
        {
          for (int j = scaleDown; j < (sizeDownWidth - (scaleDown)); j++)
          {
            largest = convolutions[b][o][p][j];
            for (int i = -scaleDown; i < scaleDown; i++)
            {
              for (int k = -scaleDown; k < scaleDown; k++)
              {
                sizeInput = convolutions[b][o][p + i][j + k];
                if (sizeInput > largest)
                {
                  largest = sizeInput;
                }
              }
            }
            scaleDownARRAY[b][o][p / scaleDown][j / scaleDown] = largest;
          }
        }
      }
      for (int o = 0; o < neurons[b]; o++)
      {
        for (int p = scaleDown; p < (sizeDownHeight - scaleDown); p++)
        {
          for (int j = scaleDown; j < (sizeDownWidth - scaleDown); j++)
          {

            convolutions[b][o][p][j] = scaleDownARRAY[b][o][p][j];
          }
        }
      }
      sizeDownHeight = sizeDownHeight / scaleDown;
      sizeDownWidth = sizeDownWidth / scaleDown;
    } else if (b == 0)
    {
      for (int o = 0; o < neurons[b]; o++)
      {
        for (int p = 0; p < (sizeDownWidth - (stride)); p++)
        {
          for (int j = 0; j < (sizeDownHeight - (stride)); j++)
          {
            for (int i = 0; i < stride; i++)
            {
              for (int k = 0; k < stride; k++)
              {
                difference += ((float)(pixels[p + i][j + k] * transformation[b][o][i][k]));
              }
            }
            if (difference < 0)
            {
              convolutions[b][o][p][j] = 0;
            } else
            {
              convolutions[b][o][p][j] = difference /(int)(Math.pow(stride, 2));
            }

            difference = 0;
          }
        }
      }
      for (int o = 0; o < neurons[b]; o++)
      {
        for (int p = 0; p < (sizeDownHeight); p++)
        {
          for (int j = scaleDown; j < (sizeDownWidth); j++)
          {

            scaleDownARRAY[b][o][p][j] = convolutions[b][o][p][j];
          }
        }
      }
    }

    if (b == neurons.length-1)
    {
     
      for (int a = 0; a < neurons[b]; a++)
      {
        for (int i = 0; i < sizeDownWidth; i++)
        {
          for (int j = 0; j < sizeDownHeight; j++)
          {
            valueOutput[a] += (scaleDownARRAY[b][a][i][j]);
            
          }
        }
       
      }
      for (int i = 0; i < valueOutput.length; i++)
        {
          valueOutput[i] = (float)(1/(1+ Math.pow(2.718281828459045,valueOutput[i])));
        }
      largestOutput = valueOutput[0];
      outputNumber = 0;
      for (int i = 0; i < neurons[b]; i++)
      {
        if (valueOutput[i] > largestOutput)
        {
          largestOutput = valueOutput[i]; 
          outputNumber = i;
        }
      }
      for (int i = 0; i < neurons[b]; i++)
      {
        valueOutput[i] = 0;
      }
    }
  }

  return outputNumber;
}