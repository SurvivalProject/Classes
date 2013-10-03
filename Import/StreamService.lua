local StreamServ = {}

function StreamServ:TemporaryStream(Name)
	local new = Create("Stream")
	new.Name = Name or "Temporary"
	new.Temporary = true
	OLDPRINT("NEW ")
	new.Parent = self
	return new
end

StreamServ = CreateClass("StreamService", StreamServ)

CreateEvent(StreamServ, "StreamAdded")
CreateEvent(StreamServ, "StreamRemoved")

StreamService = Create("StreamService")

StreamService.Name = "StreamService"
StreamServ.Uncreatable = true
StreamService.Parent = System


