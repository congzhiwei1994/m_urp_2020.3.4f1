using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace App.Render
{
    [Serializable, VolumeComponentMenu("DQ/RealTime Shadow")]
    public class RealTimeShadowVolume : VolumeComponent, IPostProcessComponent
    {
        public BoolParameter enable = new BoolParameter(false);
        public bool IsActive()
        {
            return enable.value;
        }
        public bool IsTileCompatible()
        {
            return false;
        }
    }
}

