#include "PalUIActionWidgetBase.h"

UPalUIActionWidgetBase::UPalUIActionWidgetBase() {
}

// TODO: ECommonInputType.h not found?
//void UPalUIActionWidgetBase::OverrideInputType(ECommonInputType InputType) {
//}

void UPalUIActionWidgetBase::OverrideImage(FSlateBrush OverrideBrush) {
}

FText UPalUIActionWidgetBase::GetLocalizedDisplayText() const {
    return FText::GetEmpty();
}


