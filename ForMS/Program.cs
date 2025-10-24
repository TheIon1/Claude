using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SmallBasic.Library;

namespace ForMS
{
    class Program
    {
        static void Main(string[] args)
        {
            //Create turtle-counter;
            int i = 0;
            //Starting point for our turtle
            Turtle.Angle = 180;
            //Any coordinates that left us some free space on screen for clarity would fit.
            Turtle.X = 600;
            Turtle.Y = 400;
            #region goTurtle
            while (Turtle.Angle < 540)
            {
                //If Moscow Garden ring Road 15600 in length, and we need to draw it with turtle,let's gain our angle by dividing length on turtle-segments and start moving.
                Turtle.Angle += 0.23;
                //We could say that 1 turtle move is equal to placing one turtle close to another, so that's how we get our turtle-car amount.
                Turtle.Move(1);
                //Counting
                i++;
                Console.Write("X" + Turtle.X.ToString() + "Y" + Turtle.Y.ToString());
            }
            #endregion
            //Let's write answer
            Console.WriteLine();
            Console.Write("Черепахо-машин:" + i);
        }
    }
}
