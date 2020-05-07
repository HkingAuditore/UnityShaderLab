using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Item {
    public enum MainCategory {
        KitchenWare,
        Consumables
    }

    public class KitchenWare {
        public enum KitchenWareType {
            Heat,
            Process,
            Cut,
            Container,
            Others
        }

        private MainCategory mainCategory;
        public KitchenWareType kitchenWareType;
        public KitchenWare (KitchenWareType _type) {
            this.mainCategory = MainCategory.KitchenWare;
            this.kitchenWareType = _type;
        }

        

    }
}