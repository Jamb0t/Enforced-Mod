
local orig_BiteLeap_GetRange
orig_BiteLeap_GetRange = Class_ReplaceMethod( "BiteLeap", "GetRange",
function (self)
    return kSkulkBiteRange
end
)

ReplaceLocals( BiteLeap.OnTag, { kEnzymedRange = kSkulkEnzymedRange, kRange = kSkulkBiteRange, } )
