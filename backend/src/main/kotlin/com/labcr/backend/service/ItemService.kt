package com.labcr.backend.service

import com.labcr.backend.model.Item
import com.labcr.backend.repository.ItemRepository
import org.springframework.stereotype.Service

@Service
class ItemService(private val itemRepository: ItemRepository) {

    fun findAll(): List<Item> = itemRepository.findAll()

    fun findById(id: String): Item? = itemRepository.findById(id).orElse(null)

    fun create(item: Item): Item = itemRepository.save(item.copy(id = null))

    fun update(id: String, item: Item): Item? {
        return if (itemRepository.existsById(id)) {
            itemRepository.save(item.copy(id = id))
        } else {
            null
        }
    }

    fun delete(id: String): Boolean {
        return if (itemRepository.existsById(id)) {
            itemRepository.deleteById(id)
            true
        } else {
            false
        }
    }
}
