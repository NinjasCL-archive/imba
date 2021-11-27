import {renderContext,RenderContext} from './context'
import {scheduler} from '../scheduler'

export def render blk, ctx = {}
	let prev = renderContext.context
	renderContext.context = ctx
	let res = blk(ctx)
	if renderContext.context == ctx
		renderContext.context = prev
	return res

export def mount mountable, into
	if $node$
		console.warn "imba.mount not supported on server"
		# if mountable isa Function	
		console.log String(mountable)
		return String(mountable)

	let parent = into or global.document.body
	let element = mountable
	if mountable isa Function

		let ctx = new RenderContext(parent)
		let tick = do
			let prev = renderContext.context
			renderContext.context = ctx
			let res = mountable(ctx)
			if renderContext.context == ctx
				renderContext.context = prev
			return res
		element = tick()
		scheduler.listen('commit',tick)
	else
		# automatic scheduling of element - even before
		# element.__schedule = yes
		element.__F |= $EL_SCHEDULE$

	element.#insertInto(parent)
	return element

export def unmount el
	if el and el.#removeFrom
		el.#removeFrom(el.parentNode)
	return el
		
let instance = global.imba ||= {}
instance.mount = mount
instance.unmount = unmount