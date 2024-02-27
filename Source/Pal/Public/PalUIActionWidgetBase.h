#pragma once
#include "CoreMinimal.h"
// TODO: ECommonInputType.h not found?
//#include "ECommonInputType.h"
#include "CommonActionWidget.h"
#include "Styling/SlateBrush.h"
#include "PalUIActionWidgetBase.generated.h"

UCLASS(Blueprintable)
class PAL_API UPalUIActionWidgetBase : public UCommonActionWidget {
    GENERATED_BODY()
public:
    UPalUIActionWidgetBase();

    // TODO: ECommonInputType.h not found?
    //UFUNCTION(BlueprintCallable)
    //void OverrideInputType(ECommonInputType InputType);
    
    UFUNCTION(BlueprintCallable)
    void OverrideImage(FSlateBrush OverrideBrush);
    
    UFUNCTION(BlueprintCallable, BlueprintPure)
    FText GetLocalizedDisplayText() const;
    
};

