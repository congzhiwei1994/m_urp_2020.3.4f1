using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 参数数组和数组参数


namespace Jefford.Csharp
{
    public class ArrayParameter
    {
        public int Sum1(int[] temp)
        {
            int sum = 0;
            for (var i = 0; i < temp.Length; i++)
            {
                sum += temp[i];
            }
            return sum;
        }

        public int Sum2(params int[] temp)
        {
            int sum = 0;
            for (var i = 0; i < temp.Length; i++)
            {
                sum += temp[i];
            }
            return sum;
        }
    }

}
