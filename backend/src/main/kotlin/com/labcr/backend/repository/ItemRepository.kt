package com.labcr.backend.repository

import com.labcr.backend.model.Item
import org.springframework.data.mongodb.repository.MongoRepository

interface ItemRepository : MongoRepository<Item, String>
